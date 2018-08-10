pragma solidity ^0.4.24;

contract ContentInterface {
    function updateContent(string _record, uint256 _marketerRate) external;
    function addEpisode(string _record, string _cuts, uint256 _price) external;
    function updateEpisode(uint256 _index, string _record, string _cuts, uint256 _price) external;
    function isPurchasedEpisode(uint256 _index, address _buyer) public view returns (bool);
    function getRecord() public view returns (string);
    function getWriter() public view returns (address);
    function getMarketerRate() public view returns (uint256);
    function getEpisodeLength() public view returns (uint256);
    function getEpisodeDetail(uint256 _index) external view returns (string, uint256, uint256, bool);
    function getEpisodeCuts(uint256 _index) external view returns (string result);
    function episodePurchase(uint256 _index, address _buyer, uint256 _amount) external;
    event RegisterContent(address _sender, string _name);
    event RegisterEpisode(address _sender, string _name, uint256 _index);
    event ChangeContent(address _sender, string _name);
    event ChangeEpisode(address _sender, string _name, uint256 _index);
    event EpisodePurchase(address indexed _buyer, uint256 _index);
}
