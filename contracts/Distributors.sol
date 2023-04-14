// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Distributors {
    address private adminContractAddress;
    address private productCodeContractAddress;
    address private manufacturersContractAddress;
    address private wholesalersContractAddress;

    struct Transfer {
        uint code;
        address from;
        address to;
    }

    mapping(address => Transfer[]) private productsToBeArrive;
    mapping(address => uint[]) private productsRecived;
    mapping(address => uint[]) private productsInCustody;
    mapping(address => Transfer[]) private productsToBeTransfer;

    event ArrivedProduct(uint _code, address _from, address _to);
    event TransferProduct(uint _code, address _from, address _to);

    modifier onlyAdmin() {
        require(
            IAdmin(adminContractAddress).getAdmin() == msg.sender,
            "Only Admin"
        );
        _;
    }

    modifier onlyManufacturer() {
        require(
            msg.sender == manufacturersContractAddress,
            "Only Manufacturer"
        );
        _;
    }

    modifier onlyDistributor() {
        require(
            IAdmin(adminContractAddress).isDistributor(msg.sender),
            "Only Distributor"
        );
        _;
    }

    modifier onlyWholesaler() {
        require(wholesalersContractAddress == msg.sender, "Only Wholesaler");
        _;
    }

    constructor(
        address _adminContractAddress,
        address _productCodeContractAddress,
        address _manufacturersContractAddress
    ) {
        adminContractAddress = _adminContractAddress;
        productCodeContractAddress = _productCodeContractAddress;
        manufacturersContractAddress = _manufacturersContractAddress;
    }

    function addWholesalersContractAddress(address _address) public onlyAdmin {
        wholesalersContractAddress = _address;
    }

    function productArrived(uint _code, address _from) public onlyDistributor {
        bool isValidCode;
        bool isValidAddress;
        uint index;
        uint length = productsToBeArrive[msg.sender].length;

        for (uint i = 0; i < length; i++) {
            if (_code == productsToBeArrive[msg.sender][i].code) {
                isValidCode = true;
                index = i;

                if (_from == productsToBeArrive[msg.sender][i].from) {
                    isValidAddress = true;
                }

                break;
            }
        }

        if (!isValidCode) {
            revert("Code Not Found!");
        }

        if (!isValidAddress) {
            revert("Invalid Manufacturer Address!");
        }

        if (length > 1) {
            productsToBeArrive[msg.sender][index] = productsToBeArrive[
                msg.sender
            ][length - 1];
        }

        productsToBeArrive[msg.sender].pop();

        productsRecived[msg.sender].push(_code);
        productsInCustody[msg.sender].push(_code);

        IManufacturers(manufacturersContractAddress)
            .productRecivedByDistributor(_code, _from, msg.sender);
        IProductCode(productCodeContractAddress).addSupplyChainArrival(
            _code,
            _from,
            msg.sender
        );

        emit ArrivedProduct(_code, _from, msg.sender);
    }

    function productTransfer(uint _code, address _to) public onlyDistributor {
        require(
            IAdmin(adminContractAddress).isWholesaler(_to),
            "Invalid Wholesaler Address!"
        );

        bool isValidCode;
        uint index;
        uint length = productsInCustody[msg.sender].length;

        for (uint i = 0; i < length; i++) {
            if (_code == productsInCustody[msg.sender][i]) {
                isValidCode = true;
                index = i;
                break;
            }
        }

        if (!isValidCode) {
            revert("Distributor does not have the code");
        }

        if (length > 1) {
            productsInCustody[msg.sender][index] = productsInCustody[
                msg.sender
            ][length - 1];
        }

        productsInCustody[msg.sender].pop();

        Transfer memory transfer;
        transfer.code = _code;
        transfer.from = msg.sender;
        transfer.to = _to;

        productsToBeTransfer[msg.sender].push(transfer);

        IProductCode(productCodeContractAddress).addSupplyChainTransfer(
            _code,
            msg.sender,
            _to
        );
        IWholesaler(wholesalersContractAddress).addProductToArrive(
            _code,
            msg.sender,
            _to
        );

        emit TransferProduct(_code, msg.sender, _to);
    }

    function productRecivedByWholesaler(
        uint _code,
        address _from,
        address _to
    ) public onlyWholesaler {
        bool isValidCode;
        bool isValidAddress;
        uint index;
        uint length = productsToBeTransfer[_from].length;

        for (uint i = 0; i < length; i++) {
            if (_code == productsToBeTransfer[_from][i].code) {
                isValidCode = true;
                index = i;

                if (_to == productsToBeTransfer[_from][i].to) {
                    isValidAddress = true;
                }

                break;
            }
        }

        if (!isValidCode) {
            revert("Code Not Found!");
        }

        if (!isValidAddress) {
            revert("Invalid Wholesaler Address!");
        }

        if (length > 1) {
            productsToBeTransfer[_from][index] = productsToBeTransfer[_from][
                length - 1
            ];
        }

        productsToBeTransfer[_from].pop();
    }

    function addProductToArrive(
        uint _code,
        address _from,
        address _to
    ) public onlyManufacturer {
        Transfer memory transfer;
        transfer.code = _code;
        transfer.from = _from;
        transfer.to = _to;

        productsToBeArrive[_to].push(transfer);
    }

    function getAllProductsToBeArrive()
        public
        view
        returns (Transfer[] memory)
    {
        return productsToBeArrive[msg.sender];
    }

    function getAllReciviedProducts() public view returns (uint[] memory) {
        return productsRecived[msg.sender];
    }

    function getAllProductsInCustody() public view returns (uint[] memory) {
        return productsInCustody[msg.sender];
    }

    function getAllProductsToBeTransfer()
        public
        view
        returns (Transfer[] memory)
    {
        return productsToBeTransfer[msg.sender];
    }
}

interface IAdmin {
    function getAdmin() external view returns (address);

    function isDistributor(address _address) external view returns (bool);

    function isWholesaler(address _address) external view returns (bool);
}

interface IManufacturers {
    function productRecivedByDistributor(
        uint _code,
        address _from,
        address _to
    ) external;
}

interface IProductCode {
    function isValidCurrentKeep(
        uint _code,
        address _from
    ) external view returns (bool);

    function addSupplyChainArrival(
        uint _code,
        address _fromAddress,
        address _toAddress
    ) external;

    function addSupplyChainTransfer(
        uint _code,
        address _fromAddress,
        address _toAddress
    ) external;
}

interface IWholesaler {
    function addProductToArrive(
        uint _code,
        address _from,
        address _to
    ) external;
}
