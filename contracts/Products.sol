// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Products {
    uint private code;
    address private adminAddress;
    address private admin;

    struct Product {
        string name;
        string model;
        string brand;
        string description;
        string specifications;
        string[] images;
        uint createdTime;
        uint discontinuedTime;
        bool isInProduction;
        bool isValue;
    }

    event ProductAdd(uint _productId);
    event ProductionStatusChange(uint _productId);

    mapping(uint => Product) private products;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only Admin Allowed");
        _;
    }

    constructor(address _adminAddress) {
        adminAddress = _adminAddress;
        admin = IAdmin(_adminAddress).getAdmin();
    }

    function addProduct(
        string memory _name,
        string memory _model,
        string memory _brand,
        string memory _description,
        string memory _specifications,
        string[] memory _images
    ) public onlyAdmin {
        Product memory product;
        product.name = _name;
        product.model = _model;
        product.brand = _brand;
        product.description = _description;
        product.specifications = _specifications;
        product.images = _images;
        product.createdTime = block.timestamp;
        product.isInProduction = true;
        product.isValue = true;

        products[++code] = product;

        emit ProductAdd(code);
    }

    function addProductImages(
        uint _productId,
        string[] memory _images
    ) public onlyAdmin {
        require(products[_productId].isValue, "Invalid Product Id!");
        products[_productId].images = _images;
    }

    function changeProductionStatus(uint _productId) public onlyAdmin {
        require(products[_productId].isValue, "Invalid Product Id");
        Product storage product = products[_productId];
        product.isInProduction = !product.isInProduction;
        product.discontinuedTime = block.timestamp;

        emit ProductionStatusChange(_productId);
    }

    function getCode() public view returns (uint) {
        return code;
    }

    function getProduct(uint productId) public view returns (Product memory) {
        return products[productId];
    }

    function isvalidProduct(uint productId) public view returns (bool) {
        return products[productId].isValue;
    }
}

interface IAdmin {
    function getAdmin() external view returns (address);
}
