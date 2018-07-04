pragma solidity ^0.4.23;

contract Account {

    mapping (string -> address) nickNameToAddress;
    mapping (address -> string) addressToNickName;

    modifier validAddress(address _account) {
        require(_account != address(0));
        require(_account != address(this));
        _;
    }

    constructor () public {

    }

    function createAccount(string _nickName) validAddress(msg.sender) {
        require(nickNameToAddress[_nickName] == address(0));
        require(bytes(addressToNickName[msg.sender]).length == 0);

        nickNameToAddress[_nickName] = msg.sender;
        addressToNickName[msg.sender] = _nickName;
    }

    function getNickName(address _addr) validAddress(_addr) view returns(string) {
        return addressToNickName[_addr];
    }

    function getUserAddress(string _nickName) view returns(address) {
        return nickNameToAddress[_nickName];
    }
}
