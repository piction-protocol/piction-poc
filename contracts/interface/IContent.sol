pragma solidity ^0.4.24;

contract IContent {
    function updateContent(string _record, uint256 _marketerRate) external;
    function addEpisode(string _record, string _cuts, uint256 _price) external;
    function updateEpisode(uint256 _index, string _record, string _cuts, uint256 _price) external;
    function addPickCount(address _user) external;
    function isPurchasedEpisode(uint256 _index, address _buyer) external view returns (bool isPurchased_);
    function getRecord() public view returns (string record_);
    function getWriter() public view returns (address writer_);
    function getWriterName() public view returns (string writerName_);
    function getMarketerRate() public view returns (uint256 marketerRate_);
    function getPickCount() public view returns (uint256 pickCount_);
    function getContentDetail() external view returns (string record_, address writer_, string writerName_, uint256 marketerRate_, uint256 pickCount_);
    function getEpisodeLength() public view returns (uint256 episodeLength_);
    function getEpisodeDetail(uint256 _index, address _buyer) external view returns (string record_, uint256 price_, uint256 buyCount_, bool isPurchased_);
    function getEpisodeCuts(uint256 _index) external view returns (string episodeCuts_);
    function episodePurchase(uint256 _index, address _buyer, uint256 _amount) external;
    event ContentCreation(address indexed _sender, address indexed _writer, string _writerName, string _record, uint256 _marketerRate);
    event EpisodeCreation(uint256 indexed _episodeIndexId, address indexed _contentAddress, address indexed _writer, string _record, uint256 _price);
    event ChangeContent(address indexed _contentAddress, address indexed _writer, string _record, uint256 _marketerRate);
    event ChangeEpisode(uint256 indexed _episodeIndexId, address indexed _contentAddress, address indexed _writer, string _record, uint256 _price);
    event AddPickCount(address indexed _contentAddress, address indexed _userAddress, uint256 _totalPickCount);
    event EpisodePurchase(uint256 indexed _episodeIndexId, address indexed _contentAddress, address indexed _buyer, uint256 _price, uint256 _episodePurchaseCount);
}
