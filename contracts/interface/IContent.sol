pragma solidity ^0.4.24;

contract IContent {
    function updateContent(string _record, bool _isPublished, uint256 _publishDate) external;
    function addEpisode(string _record, string _cuts, uint256 _price, bool _isPublished, uint256 _publishDate) external;
    function updateEpisode(uint256 _index, string _record, string _cuts, uint256 _price, bool _isPublished, uint256 _publishDate) external;
    function isPurchasedEpisode(uint256 _index, address _buyer) external view returns (bool isPurchased_);
    function getRecord() public view returns (string record_);
    function getWriter() public view returns (address writer_);
    function getWriterName() public view returns (string writerName_);
    function getIsPublished() public view returns (bool isPublished_);
    function getPublishDate() public view returns (uint256 publishDate_);
    function getTotalPurchasedCount() public view returns (uint256 totalPurchasedCount_);
    function getTotalPurchasedAmount() public view returns (uint256 totalPurchasedAmount_);
    function getContentCreationTime() public view returns (uint256 contentCreationTime_);
    function getEpisodeLastUpdatedTime() public view returns (uint256 episodeLastUpdatedTime_);
    function getIsPublisheContent() external view returns (bool isPublished_);
    function getComicsInfo() external view returns(string record_, address writer_, string writerName_, bool isPublished_, uint256 publishDate_, uint256 totalPurchasedCount_, uint256 totalPurchasedAmount_, uint256 contentCreationTime_, uint256 episodeLastUpdatedTime_);
    function getEpisodeLength() public view returns (uint256 episodeLength_);
    function getPublishEpisodeIndex() public view returns (uint256[] episodeIndex_);
    function getEpisodeDetail(uint256 _index, address _buyer) external view returns (string record_, uint256 price_, uint256 buyCount_, bool isPurchased_, bool isPublished_, uint256 publishDate_, uint256 episodeCreationTime_);
    function getEpisodeCuts(uint256 _index) external view returns (string episodeCuts_);
    function episodePurchase(uint256 _index, address _buyer, uint256 _amount) external;
    event ContentCreation(address indexed _sender, address indexed _writer, string _writerName, string _record, bool _isPublished, uint256 _publishDate, uint256 _contentCreationTime);
    event EpisodeCreation(uint256 indexed _episodeIndexId, address indexed _contentAddress, address indexed _writer, string _record, uint256 _price, bool _isPublished, uint256 _publishDate, uint256 _episodeCreationTime);
    event ChangeContent(address indexed _contentAddress, address indexed _writer, string _record, bool _isPublished, uint256 _publishDate);
    event ChangeEpisode(uint256 indexed _episodeIndexId, address indexed _contentAddress, address indexed _writer, string _record, uint256 _price, bool _isPublished, uint256 _publishDate);
    event EpisodePurchase(uint256 indexed _episodeIndexId, address indexed _contentAddress, address indexed _buyer, uint256 _price, uint256 _episodePurchaseCount);
}
