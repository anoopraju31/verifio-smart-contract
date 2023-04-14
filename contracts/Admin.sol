// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Admin {
    address private admin;
    address private customersContractAddress;

    bytes32 private constant MANUFACTURER = keccak256("MANUFACTURER");
    bytes32 private constant DISTRIBUTOR = keccak256("DISTRIBUTOR");
    bytes32 private constant WHOLESALER = keccak256("WHOLESALER");
    bytes32 private constant RETAILER = keccak256("RETAILER");
    bytes32 private constant CUSTOMER = keccak256("CUSTOMER");

    struct SupplyPlayer {
        string role;
        string name;
        string owner;
        string email;
        string contactAddress;
        string[] images;
        address walletAddress;
        uint phone;
        uint createdTime;
        bool isBlocked;
        bool isValue;
    }

    event SupplyPlayerAdd(address _address, string _role);

    mapping(address => SupplyPlayer) private manufacturers;
    mapping(address => SupplyPlayer) private distributors;
    mapping(address => SupplyPlayer) private wholesalers;
    mapping(address => SupplyPlayer) private retailers;
    mapping(address => string) private roles;
    mapping(string => address[]) private players;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only Admin Allowed");
        _;
    }

    modifier onlyCustomer() {
        require(msg.sender == customersContractAddress, "Only Customer");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function addCustomersContractAddress(
        address _customersContractAddress
    ) public onlyAdmin {
        customersContractAddress = _customersContractAddress;
    }

    function getAdmin() public view returns (address) {
        return admin;
    }

    function addSupplyPlayer(
        string memory _role,
        string memory _name,
        string memory _owner,
        string memory _email,
        string memory _contactAddress,
        string[] memory _images,
        address _walletAddress,
        uint _phone
    ) public onlyAdmin {
        bytes32 role = keccak256(bytes(_role));

        SupplyPlayer memory player;
        player.name = _name;
        player.role = _role;
        player.owner = _owner;
        player.email = _email;
        player.contactAddress = _contactAddress;
        player.images = _images;
        player.walletAddress = _walletAddress;
        player.phone = _phone;
        player.createdTime = block.timestamp;
        player.isBlocked = false;
        player.isValue = true;

        if (role == MANUFACTURER) {
            manufacturers[_walletAddress] = player;
        } else if (role == DISTRIBUTOR) {
            distributors[_walletAddress] = player;
        } else if (role == WHOLESALER) {
            wholesalers[_walletAddress] = player;
        } else if (role == RETAILER) {
            retailers[_walletAddress] = player;
        }

        players[_role].push(_walletAddress);
        roles[_walletAddress] = _role;

        emit SupplyPlayerAdd(_walletAddress, _role);
    }

    function addCustomer(address _address) public onlyCustomer {
        roles[_address] = "CUSTOMER";
        players["CUSTOMER"].push(_address);
    }

    function getRole(address _address) public view returns (string memory) {
        return roles[_address];
    }

    function isManufacturer(address _address) public view returns (bool) {
        bytes32 role = keccak256(bytes(roles[_address]));
        return role == MANUFACTURER;
    }

    function isDistributor(address _address) public view returns (bool) {
        bytes32 role = keccak256(bytes(roles[_address]));
        return role == DISTRIBUTOR;
    }

    function isWholesaler(address _address) public view returns (bool) {
        bytes32 role = keccak256(bytes(roles[_address]));
        return role == WHOLESALER;
    }

    function isRetailer(address _address) public view returns (bool) {
        bytes32 role = keccak256(bytes(roles[_address]));
        return role == RETAILER;
    }

    function isCustomer(address _address) public view returns (bool) {
        bytes32 role = keccak256(bytes(roles[_address]));
        return role == CUSTOMER;
    }

    function getManufacturer(
        address _address
    ) public view returns (SupplyPlayer memory) {
        return manufacturers[_address];
    }

    function getDistributor(
        address _address
    ) public view returns (SupplyPlayer memory) {
        return distributors[_address];
    }

    function getWholesaler(
        address _address
    ) public view returns (SupplyPlayer memory) {
        return wholesalers[_address];
    }

    function getRetailer(
        address _address
    ) public view returns (SupplyPlayer memory) {
        return retailers[_address];
    }

    function getPlayers(
        string memory _type
    ) public view returns (address[] memory) {
        return players[_type];
    }
}
