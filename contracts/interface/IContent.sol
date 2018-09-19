pragma solidity ^0.4.24;

contract IContent {
    function updateContent(string _record, uint256 _marketerRate) external;
    function addEpisode(string _record, string _cuts, uint256 _price) external;
    function updateEpisode(uint256 _index, string _record, string _cuts, uint256 _price) external;
    function isPurchasedEpisode(uint256 _index, address _buyer) external view returns (bool isPurchased_);
    function getRecord() public view returns (string record_);
    function getWriter() public view returns (address writer_);
    function getMarketerRate() public view returns (uint256 marketerRate_);
    function getEpisodeLength() public view returns (uint256 episodeLength_);
    function getEpisodeDetail(uint256 _index, address _buyer) external view returns (bytes record_, uint256 price_, uint256 buyCount_, bool isPurchased_);
    function getEpisodeCuts(uint256 _index) external view returns (string episodeCuts_);
    function episodePurchase(uint256 _index, address _buyer, uint256 _amount) external;
    event RegisterContent(address _sender, string _name);
    event RegisterEpisode(address _sender, string _name, uint256 _index);
    event ChangeContent(address _sender, string _name);
    event ChangeEpisode(address _sender, string _name, uint256 _index);
    event EpisodePurchase(address indexed _buyer, uint256 _index);
}
