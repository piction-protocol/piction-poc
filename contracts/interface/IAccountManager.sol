pragma solidity ^0.4.24;

contract IAccountManager {
    function createNewAccount(string _userName, string _password, string _privateKey, address _wallet) external;
    function login(string _userName, string _password) external view returns (string key_, bool result_);
    function setPurchaseContentsAddress(address _contentAddress, address _buyer) external;
    function isRegistered(string _userName) public view returns (bool isRegistered_);
    function getUserName(address _wallet) external view returns (string userName_, bool result_);
    event RegisterNewAccount(uint256 indexed _index, address indexed _walletAddress, string _userName);
    event PurchaseContentsAddress(address indexed _buyer, address indexed _contentsAddress);
}
