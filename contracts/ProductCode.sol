// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProductCode {
    address private admin;
    address private adminContractAddress;
    address private manufacturerContractAddress;
    address private distributorContractAddress;
    address private wholesalerContractAddress;
    address private retailerContractAddress;
    address private customerContractAddress;

    struct SupplyChain {
        address keeper;
        uint receivalTime;
        address transferTo;
        uint departureTime;
    }

    struct Code {
        uint productId;
        uint8 status;
        SupplyChain[] supplyChain;
        address currentOwner;
        bool isValue;
    }

    event CodeAdd(uint _code);
    event CodeTransfer(uint _code, address _from, address _to);
    event CodeRecive(uint _code, address _from, address _to);
    event CodeStatus(uint _code, uint8 _status);

    mapping(uint => Code) private codes;

    modifier onlyManufacturer() {
        require(
            msg.sender == manufacturerContractAddress,
            "Only Manufacturer Contract"
        );
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only Admin!");
        _;
    }

    modifier validCode(uint _code) {
        require(codes[_code].isValue, "Invalid Code");
        _;
    }

    modifier validUser() {
        require(
            msg.sender == manufacturerContractAddress ||
                msg.sender == distributorContractAddress ||
                msg.sender == wholesalerContractAddress ||
                msg.sender == retailerContractAddress ||
                msg.sender == customerContractAddress,
            "Only Valid User Allowed"
        );
        _;
    }

    constructor(address _adminContractAddress) {
        adminContractAddress = _adminContractAddress;
        admin = IAdmin(_adminContractAddress).getAdmin();
    }

    function addManufacturerContractAddress(address _address) public onlyAdmin {
        manufacturerContractAddress = _address;
    }

    function addDistributorContractAddress(address _address) public onlyAdmin {
        distributorContractAddress = _address;
    }

    function addWholesalerContractAddress(address _address) public onlyAdmin {
        wholesalerContractAddress = _address;
    }

    function addRetailerContractAddress(address _address) public onlyAdmin {
        retailerContractAddress = _address;
    }

    function addCustomerContractAddress(address _address) public onlyAdmin {
        customerContractAddress = _address;
    }

    function addCode(
        uint _code,
        uint _productId,
        address _manufacturerAddress
    ) public onlyManufacturer {
        Code storage code = codes[_code];
        code.productId = _productId;
        code.status = 0;
        code.isValue = true;

        SupplyChain memory supplyChain;
        supplyChain.keeper = _manufacturerAddress;
        supplyChain.receivalTime = block.timestamp;

        code.supplyChain.push(supplyChain);

        emit CodeAdd(_code);
    }

    function addSupplyChainTransfer(
        uint _code,
        address _from,
        address _to
    ) public validCode(_code) validUser {
        Code storage code = codes[_code];
        uint lastIndex = code.supplyChain.length - 1;

        require(
            code.supplyChain[lastIndex].transferTo == address(0) &&
                code.supplyChain[lastIndex].keeper == _from,
            "Product Already Transfered!"
        );

        code.supplyChain[lastIndex].transferTo = _to;
        code.supplyChain[lastIndex].departureTime = block.timestamp;

        emit CodeTransfer(_code, _from, _to);
    }

    function addSupplyChainArrival(
        uint _code,
        address _from,
        address _to
    ) public validCode(_code) validUser {
        Code storage code = codes[_code];

        uint lastIndex = code.supplyChain.length - 1;
        require(
            code.supplyChain[lastIndex].transferTo == _to &&
                code.supplyChain[lastIndex].keeper == _from,
            "Product Already Transfered!"
        );

        SupplyChain memory supplyChain;
        supplyChain.keeper = _to;
        supplyChain.receivalTime = block.timestamp;

        code.supplyChain.push(supplyChain);

        emit CodeRecive(_code, _from, _to);
    }

    function changeStatus(uint _code, uint8 _status) public validCode(_code) {
        require(
            msg.sender == retailerContractAddress ||
                msg.sender == customerContractAddress,
            "Only Customer and Retailer Allowed"
        );

        codes[_code].status = _status;

        emit CodeStatus(_code, _status);
    }

    function addUser(uint _code, address _address) public {
        require(
            msg.sender == retailerContractAddress ||
                msg.sender == customerContractAddress,
            "Only Customer and Retailer Allowed"
        );
        codes[_code].currentOwner = _address;
    }

    function changeOwner(uint _code, address _address) public {
        require(msg.sender == customerContractAddress, "Only Customer Allowed");

        Code storage code = codes[_code];
        code.currentOwner = _address;
        code.status = 2;
        code.supplyChain[code.supplyChain.length - 1].transferTo = _address;
        code.supplyChain[code.supplyChain.length - 1].departureTime = block
            .timestamp;
    }

    function getCode(uint _code) public view returns (Code memory) {
        return codes[_code];
    }

    function isValidCurrentKeep(
        uint _code,
        address _from
    ) public view validCode(_code) returns (bool) {
        uint length = codes[_code].supplyChain.length;
        require(
            codes[_code].supplyChain[length - 1].transferTo == address(0),
            "Product Is In Transfer"
        );
        return codes[_code].supplyChain[length - 1].keeper == _from;
    }
}

interface IAdmin {
    function getAdmin() external view returns (address);

    function isManufacturer(address _address) external view returns (bool);
}
