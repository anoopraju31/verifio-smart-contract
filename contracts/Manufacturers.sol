// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Manufacturers {
    address private adminContractAddress;
    address private productsContractAddress;
    address private productCodeContractAddress;
    address private distributorsContractAddress;

    uint private code;
    bool public lock;

    struct Transfer {
        uint code;
        address from;
        address to;
    }

    mapping(address => uint[]) private manufactureredProducts;
    mapping(address => uint[]) private productsInCustody;
    mapping(address => Transfer[]) private productsToBeTransfer;

    event CodeCreate(uint _code);
    event ProductTransfer(uint _code, address _from, address _to);

    modifier onlyAdmin() {
        require(
            IAdmin(adminContractAddress).getAdmin() == msg.sender,
            "Only Admin"
        );
        _;
    }

    modifier onlyManufacturer() {
        require(
            IAdmin(adminContractAddress).isManufacturer(msg.sender),
            "Only Manufacturer"
        );
        _;
    }

    modifier onlyDistributor() {
        require(distributorsContractAddress == msg.sender, "Only Distributor");
        _;
    }

    constructor(
        address _adminContractAddress,
        address _productsContractAddress,
        address _productCodeContractAddress
    ) {
        adminContractAddress = _adminContractAddress;
        productsContractAddress = _productsContractAddress;
        productCodeContractAddress = _productCodeContractAddress;
    }

    function addDistributorsContractAddress(address _address) public onlyAdmin {
        distributorsContractAddress = _address;
    }

    function createCode(uint _productId) public onlyManufacturer {
        require(
            IProduct(productsContractAddress).isvalidProduct(_productId),
            "Invalid Product Id"
        );
        require(!lock, "Mutex Locked");

        lock = true;
        code++;

        uint generatedCode = uint(keccak256(abi.encode(code)));
        IProductCode(productCodeContractAddress).addCode(
            generatedCode,
            _productId,
            msg.sender
        );
        manufactureredProducts[msg.sender].push(generatedCode);
        productsInCustody[msg.sender].push(generatedCode);

        emit CodeCreate(generatedCode);

        lock = false;
    }

    function transferProduct(uint _code, address _to) public onlyManufacturer {
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
            revert("Manufacturer Does have the code");
        }

        Transfer memory transfer;
        transfer.code = _code;
        transfer.from = msg.sender;
        transfer.to = _to;

        if (length > 1) {
            productsInCustody[msg.sender][index] = productsInCustody[
                msg.sender
            ][length - 1];
        }

        productsInCustody[msg.sender].pop();

        productsToBeTransfer[msg.sender].push(transfer);

        IProductCode(productCodeContractAddress).addSupplyChainTransfer(
            _code,
            msg.sender,
            _to
        );
        IDistributor(distributorsContractAddress).addProductToArrive(
            _code,
            msg.sender,
            _to
        );

        emit ProductTransfer(_code, msg.sender, _to);
    }

    function productRecivedByDistributor(
        uint _code,
        address _from,
        address _to
    ) public onlyDistributor {
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
            revert("Invalid Distributor Address!");
        }

        if (length > 1) {
            productsToBeTransfer[_from][index] = productsToBeTransfer[_from][
                length - 1
            ];
        }

        productsToBeTransfer[_from].pop();
    }

    function getManufactureredProducts() public view returns (uint[] memory) {
        return manufactureredProducts[msg.sender];
    }

    function getProductInCustody() public view returns (uint[] memory) {
        return productsInCustody[msg.sender];
    }

    function getProductsToBeTransfer() public view returns (Transfer[] memory) {
        return productsToBeTransfer[msg.sender];
    }
}

interface IAdmin {
    function getAdmin() external view returns (address);

    function isManufacturer(address _address) external view returns (bool);

    function isDistributor(address _address) external view returns (bool);
}

interface IProductCode {
    function addCode(
        uint _code,
        uint _productId,
        address _manufacturerAddress
    ) external;

    function addSupplyChainTransfer(
        uint _code,
        address _fromAddress,
        address _toAddress
    ) external;
}

interface IProduct {
    function isvalidProduct(uint productId) external view returns (bool);
}

interface IDistributor {
    function addProductToArrive(
        uint _code,
        address _from,
        address _to
    ) external;
}
