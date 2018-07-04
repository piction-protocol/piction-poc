pragma solidity ^0.4.23;

contract Account {

    mapping (string => address) userNameToAddress;
    mapping (address => string) addressToUserName;

    modifier validAddress(address _account) {
        require(_account != address(0));
        require(_account != address(this));
        _;
    }

    constructor () public {

    }

    function createAccount(string _userName) validAddress(msg.sender) {
        require(userNameToAddress[_userName] == address(0));
        require(bytes(addressToUserName[msg.sender]).length == 0);

        userNameToAddress[_userName] = msg.sender;
        addressToUserName[msg.sender] = _userName;
    }

    function getUserName(address _addr) validAddress(_addr) view returns(string) {
        return addressToUserName[_addr];
    }

    function getUserAddress(string _userName) view returns(address) {
        return userNameToAddress[_userName];
    }
}
