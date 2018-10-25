pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/interface/IContent.sol";
import "contracts/interface/ICouncil.sol";

import "contracts/utils/ValidValue.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/BytesLib.sol";
import "contracts/utils/TimeLib.sol";

contract Content is IContent, ExtendsOwnable, ValidValue {
    using SafeMath for uint256;
    using BytesLib for bytes;
    using TimeLib for *;

    struct Episode {
        string record;
        string cuts;
        uint256 price;
        uint256 buyCount;
        uint256 publishDate;
        uint256 episodeCreationTime;
        uint256 episodePurchasedAmount;
        bool isPublished;
        mapping (address => bool) buyUser;
    }

    mapping (address => bool) isBuyer;

    ICouncil council;
    Episode[] episodes;

    string record;
    address writer;
    string writerName;
    
    uint256 totalPurchasedCount;
    uint256 totalPurchasedAmount;
    uint256 totalPurchasedUserCount;

    uint256 contentCreationTime;
    uint256 episodeLastUpdatedTime;

    uint256 favoriteCount;

    bool isBlocked;

    modifier validEpisodeLength(uint256 _index) {
        require(episodes.length > _index);
        _;
    }

    modifier validAccessAddress(address _apiAddress) {
        require(council.getApiContents() == _apiAddress, "Acces failed: Only Access to ApiContents smart contract.");
        _;
    }

    constructor(
        string _record,
        address _writer,
        string _writerName,
        address _council
    )
        public
        validAddress(_writer) validString(_record)
        validAddress(_council) validString(_writerName)
    {
        record = _record;
        writer = _writer;
        writerName = _writerName;

        contentCreationTime = TimeLib.currentTime();

        council = ICouncil(_council);

        emit ContentCreation(msg.sender, _writer, _writerName, _record, contentCreationTime);
    }

    function updateContent(
        string _record
    )
        external
        validAccessAddress(msg.sender)
    {
        record = _record;

        emit ChangeContent(address(this), writer, _record);
    }

    function addEpisode(
        string _record, 
        string _cuts, 
        uint256 _price,
        bool _isPublished,
        uint256 _publishDate
    )
        external
        validAccessAddress(msg.sender)
    {
        uint256 episodeCreationTime = TimeLib.currentTime();
        episodes.push(Episode(_record, _cuts, _price, 0, _publishDate, episodeCreationTime, 0, _isPublished));
        episodeLastUpdatedTime = episodeCreationTime;

        emit EpisodeCreation(episodes.length.sub(1), address(this), writer, _record, _price, _isPublished, _publishDate, episodeCreationTime);
    }

    function updateEpisode(
        uint256 _index, 
        string _record, 
        string _cuts, 
        uint256 _price,
        bool _isPublished,
        uint256 _publishDate
    )
        external
        validAccessAddress(msg.sender)
    {
        episodes[_index].record = _record;
        episodes[_index].cuts = _cuts;
        episodes[_index].price = _price;
        episodes[_index].isPublished = _isPublished;
        episodes[_index].publishDate = _publishDate;

        emit ChangeEpisode(_index, address(this), writer, _record, _price, _isPublished, _publishDate);
    }

    function updateFavoriteCount(bool isFavorite) public {
        if(isFavorite) {
            favoriteCount = favoriteCount.sub(1);
        } else {
            favoriteCount = favoriteCount.add(1);
        }
    }

    function getRecord() public view returns (string record_) {
        record_ = record;
    }

    function getWriter() public view returns (address writer_) {
        writer_ =  writer;
    }

    function getWriterName() public view returns (string writerName_) {
        writerName_ =  writerName;
    }

    function getTotalPurchasedCount() public view returns (uint256 totalPurchasedCount_) {
        totalPurchasedCount_ = totalPurchasedCount;
    }

    function getTotalPurchasedAmount() public view returns (uint256 totalPurchasedAmount_) {
        totalPurchasedAmount_ = totalPurchasedAmount;
    }

    function getTotalPurchasedUserCount() public view returns (uint256 totalPurchasedUserCount_) {
        totalPurchasedUserCount_ = totalPurchasedUserCount;
    }

    function getContentCreationTime() public view returns (uint256 contentCreationTime_) {
        contentCreationTime_ = contentCreationTime;
    }

    function getEpisodeLastUpdatedTime() public view returns (uint256 episodeLastUpdatedTime_) {
        episodeLastUpdatedTime_ = episodeLastUpdatedTime;
    }

    function getFavoriteCount() public view returns (uint256 favoriteCount_) {
        favoriteCount_ = favoriteCount;
    }

    function getSalesInfo() 
        public 
        view 
        returns (
            uint256 totalPurchasedAmount_,
            uint256 totalPurchasedCount_,
            uint256 favoriteCount_,
            uint256 totalPurchasedUserCount_
        )
    {
        totalPurchasedAmount_ = totalPurchasedAmount;
        totalPurchasedCount_ = totalPurchasedCount;
        favoriteCount_ = favoriteCount;
        totalPurchasedUserCount_ = totalPurchasedUserCount;
    }

    function getComicsInfo()
        external
        view
        returns(
            string record_,
            address writer_,
            string writerName_,
            uint256 totalPurchasedCount_,
            uint256 totalPurchasedAmount_,
            uint256 contentCreationTime_,
            uint256 episodeLastUpdatedTime_
        )
    {
        record_ = record;
        writer_ = writer;
        writerName_ = writerName;
        totalPurchasedCount_ = totalPurchasedCount;
        totalPurchasedAmount_ = totalPurchasedAmount;
        contentCreationTime_ = contentCreationTime;
        episodeLastUpdatedTime_ = episodeLastUpdatedTime;
    }

    function getEpisodeLength() public view returns (uint256 episodeLength_) {
        episodeLength_ = episodes.length;
    }

    function getPublishEpisodeIndex() public view returns (uint256[] episodeIndex_) {
        uint256 idx;
        uint256 publishLength;

        for(uint i = 0 ; i < episodes.length ; i++) {
            if(episodes[i].isPublished && episodes[i].publishDate < TimeLib.currentTime()) {
                publishLength = publishLength.add(1);
            }
        }

        episodeIndex_ = new uint256[](publishLength);

        for(i = 0 ; i < episodes.length ; i++) {
            if(episodes[i].isPublished && episodes[i].publishDate < TimeLib.currentTime()) {
                episodeIndex_[idx] = i;
                idx++;
            }
        }
    }

    function isPublishedEpisode(uint256 _index)
        external
        view
        returns (bool isPublished_)
    {
        isPublished_ = (episodes[_index].isPublished && episodes[_index].publishDate < TimeLib.currentTime())? true : false;
    }

    function isPurchasedEpisode(uint256 _index, address _buyer)
        external
        view
        returns (bool isPurchased_)
    {
        if(episodes[_index].buyUser[_buyer] || writer == _buyer) {
            isPurchased_ = true;
        }
    }

    function getEpisodeDetail(uint256 _index, address _buyer)
        external
        view
        returns (
            string record_, 
            uint256 price_, 
            uint256 buyCount_,
            uint256 purchasedAmount_,
            bool isPurchased_,
            bool isPublished_,
            uint256 publishDate_,
            uint256 episodeCreationTime_
        )
    {
        if(isBlocked) {
            return;
        }

        record_ = episodes[_index].record;
        price_ = episodes[_index].price;
        buyCount_ = episodes[_index].buyCount;
        purchasedAmount_ = episodes[_index].episodePurchasedAmount;
        isPurchased_ = episodes[_index].buyUser[_buyer];
        isPublished_ = episodes[_index].isPublished;
        publishDate_ = episodes[_index].publishDate;
        episodeCreationTime_ = episodes[_index].episodeCreationTime;
    }

    function getEpisodeCuts(uint256 _index, address _user)
        external
        view
        returns (string episodeCuts_)
    {
        if(isBlocked || council.getApiContents() != msg.sender) {
            return;
        }

        if(_user == writer) {
            episodeCuts_ = episodes[_index].cuts;
        } else {
            if(!episodes[_index].isPublished || episodes[_index].publishDate > TimeLib.currentTime()) {
                return;
            }
            episodeCuts_ = episodes[_index].cuts;
        }
    }

    function getIsBlocked()
        external
        view
        returns (bool isBlocked_)
    {
        isBlocked_ = isBlocked;
    }

    function setIsBlocked(bool _isBlocked)
        external
    {
        require(msg.sender == address(council), "Content blocking failed : access denied");

        isBlocked = _isBlocked;
        emit ContentBlocking(writer, address(this), isBlocked);
    }

    function episodePurchase(uint256 _index, address _buyer, uint256 _amount)
        external
        validAddress(_buyer) validEpisodeLength(_index)
    {
        require(council.getPixelDistributor() == msg.sender);
        require(!episodes[_index].buyUser[_buyer]);
        require(episodes[_index].price == _amount);

        episodes[_index].buyUser[_buyer] = true;
        episodes[_index].buyCount = episodes[_index].buyCount.add(1);
        episodes[_index].episodePurchasedAmount = episodes[_index].episodePurchasedAmount.add(_amount);

        totalPurchasedCount = totalPurchasedCount.add(1);
        totalPurchasedAmount = totalPurchasedAmount.add(_amount);

        if(!isBuyer[_buyer]) {
            isBuyer[_buyer] = true;
            totalPurchasedUserCount = totalPurchasedUserCount.add(1);
        }

        emit EpisodePurchase(_index, address(this), _buyer, _amount, episodes[_index].buyCount);
    }
}
