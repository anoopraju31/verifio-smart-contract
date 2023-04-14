// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Customers {
    address private adminContractAddress;
    address private productCodeContractAddress;
    address private retailerContractAddress;

    struct Customer {
        string name;
        string profile;
        string contactAddress;
        address walletAddress;
        uint64 phone;
        uint createdTime;
        uint[] products;
        bool isValue;
    }

    struct Transfer {
        uint code;
        address from;
        address to;
    }

    event CustomerAdd(address _address);

    mapping(address => Customer) private customers;
    mapping(address => Transfer[]) private productsToBeArrive;

    modifier onlyCustomer() {
        require(
            IAdmin(adminContractAddress).isCustomer(msg.sender),
            "Only Customer"
        );
        _;
    }

    modifier onlyRetailer() {
        require(msg.sender == retailerContractAddress, "Only retailer allowed");
        _;
    }

    constructor(
        address _adminContractAddress,
        address _productCodeContractAddress,
        address _retailerContractAddress
    ) {
        adminContractAddress = _adminContractAddress;
        productCodeContractAddress = _productCodeContractAddress;
        retailerContractAddress = _retailerContractAddress;
    }

    function createCustomer(
        address _address,
        string memory _name,
        string memory _profile,
        string memory _contactAddress,
        uint64 _phone
    ) public {
        Customer memory customer;
        customer.name = _name;
        customer.profile = _profile;
        customer.contactAddress = _contactAddress;
        customer.walletAddress = _address;
        customer.phone = _phone;
        customer.createdTime = block.timestamp;
        customer.isValue = true;

        customers[_address] = customer;

        IAdmin(adminContractAddress).addCustomer(_address);

        emit CustomerAdd(_address);
    }

    function reportStolen(uint _code) public onlyCustomer {
        bool isValidCode;
        uint index;
        uint length = customers[msg.sender].products.length;

        for (uint i = 0; i < length; i++) {
            if (_code == customers[msg.sender].products[i]) {
                isValidCode = true;
                index = i;
                break;
            }
        }

        if (!isValidCode) {
            revert("Customer does not have the code!");
        }

        IProductCode(productCodeContractAddress).changeStatus(_code, 3);
    }

    function transferOwnership(
        uint _code,
        address _address
    ) public onlyCustomer {
        require(
            IAdmin(adminContractAddress).isCustomer(_address),
            "Should be a valid customer"
        );

        bool isValidCode;
        uint index;
        uint length = customers[msg.sender].products.length;

        for (uint i = 0; i < length; i++) {
            if (_code == customers[msg.sender].products[i]) {
                isValidCode = true;
                index = i;
                break;
            }
        }

        if (!isValidCode) {
            revert("Customer does not have the code!");
        }

        IProductCode(productCodeContractAddress).changeOwner(_code, _address);

        Transfer memory transfer;
        transfer.code = _code;
        transfer.from = msg.sender;
        transfer.to = _address;

        productsToBeArrive[_address].push(transfer);

        if (length > 1) {
            customers[msg.sender].products[index] = customers[msg.sender]
                .products[length - 1];
        }
        customers[msg.sender].products.pop();
    }

    function acceptOwnership(uint _code, address _from) public onlyCustomer {
        bool isValidCode;
        bool isValidAddress;
        uint index;
        uint length = productsToBeArrive[msg.sender].length;

        for (uint i = 0; i < length; i++) {
            if (_code == productsToBeArrive[msg.sender][i].code) {
                isValidCode = true;
                index = i;
                if (productsToBeArrive[msg.sender][i].from == _from) {
                    isValidAddress = true;
                }
                break;
            }
        }

        if (!isValidCode) {
            revert("Customer does not have the code!");
        }

        if (!isValidAddress) {
            revert("Invalid Address");
        }

        if (length > 1) {
            productsToBeArrive[msg.sender][index] = productsToBeArrive[
                msg.sender
            ][length - 1];
        }

        productsToBeArrive[msg.sender].pop();

        customers[msg.sender].products.push(_code);

        IProductCode(productCodeContractAddress).addSupplyChainArrival(
            _code,
            _from,
            msg.sender
        );
    }

    function productRecived(uint _code, address _from) public onlyCustomer {
        bool isValidCode;
        bool isValidAddress;
        uint index;
        uint length = productsToBeArrive[msg.sender].length;

        for (uint i = 0; i < length; i++) {
            if (_code == productsToBeArrive[msg.sender][i].code) {
                isValidCode = true;
                index = i;
                if (productsToBeArrive[msg.sender][i].from == _from) {
                    isValidAddress = true;
                }
                break;
            }
        }

        if (!isValidCode) {
            revert("Customer does not have the code!");
        }

        if (!isValidAddress) {
            revert("Invalid Address");
        }

        if (length > 1) {
            productsToBeArrive[msg.sender][index] = productsToBeArrive[
                msg.sender
            ][length - 1];
        }

        productsToBeArrive[msg.sender].pop();

        customers[msg.sender].products.push(_code);

        IRetailer(retailerContractAddress).productRecivedByCustomer(
            _code,
            _from,
            msg.sender
        );
        IProductCode(productCodeContractAddress).addSupplyChainArrival(
            _code,
            _from,
            msg.sender
        );
        IProductCode(productCodeContractAddress).addUser(_code, msg.sender);
        IProductCode(productCodeContractAddress).changeStatus(_code, 1);
    }

    function addProductToArrive(
        uint _code,
        address _from,
        address _to
    ) public onlyRetailer {
        Transfer memory transfer;
        transfer.code = _code;
        transfer.from = _from;
        transfer.to = _to;

        productsToBeArrive[_to].push(transfer);
    }

    function getCustomer(
        address _address
    ) public view returns (Customer memory) {
        return customers[_address];
    }

    function getAllProductsToBeArrive()
        public
        view
        returns (Transfer[] memory)
    {
        return productsToBeArrive[msg.sender];
    }
}

interface IAdmin {
    function addCustomer(address _address) external;

    function isCustomer(address _address) external view returns (bool);
}

interface IProductCode {
    function changeStatus(uint _code, uint8 _status) external;

    function changeOwner(uint _code, address _address) external;

    function addSupplyChainArrival(
        uint _code,
        address _from,
        address _to
    ) external;

    function addUser(uint _code, address _address) external;
}

interface IRetailer {
    function productRecivedByCustomer(
        uint _code,
        address _from,
        address _to
    ) external;
}
