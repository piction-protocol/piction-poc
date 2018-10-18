pragma solidity ^0.4.24;

contract IAccountManager {
    function createNewAccount(string _userName, string _password, string _privateKey, address _wallet) external;
    function login(string _userName, string _password) external view returns (string key_, bool result_);
    function setPurchaseHistory(address _buyer, address _contentsAddress, uint256 _episodeIndex, uint256 _episodePrice) external;
    function setSupportHistory(address _supporter, address _contentsAddress, address _fundAddress, uint256 _investedAmount, bool _refund) external;
    function changeFavoriteContent(address _user, address _contentAddress) external;
    function getFavoriteContent(address _user, address _contentAddress) external view returns (bool isFavoriteContent_);
    function isRegistered(string _userName) public view returns (bool isRegistered_);
    function getUserName(address _wallet) external view returns (string userName_, bool result_);
    event RegisterNewAccount(uint256 indexed _index, address indexed _walletAddress, string _userName);
    event PurchaseHistory(address indexed _buyer, address indexed _contentsAddress, uint256 _episodeIndex, uint256 _episodePrice);
    event SupportHistory(address indexed _supporter, address indexed _contentsAddress, address indexed _fundAddress, uint256 _investedAmount, bool _refund);
}
