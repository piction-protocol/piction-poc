pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/interface/IContent.sol";
import "contracts/interface/ICouncil.sol";

import "contracts/utils/ValidValue.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/BytesLib.sol";

contract Content is IContent, ExtendsOwnable, ValidValue {
    using SafeMath for uint256;
    using BytesLib for bytes;

    struct Episode {
        string record;
        string cuts;
        uint256 price;
        uint256 buyCount;
        mapping (address => bool) buyUser;
    }

    ICouncil council;
    string public record;
    address public writer;
    uint256 public marketerRate;
    Episode[] episodes;

    modifier validEpisodeLength(uint256 _index) {
        require(episodes.length > _index);
        _;
    }

    modifier validAccessAddress(address _apiAddress) {
        require(council.getApiContents() == _apiAddress,
                "Acces failed: Only Access to ApiContents smart contract.");
        _;
    }

    constructor(
        string _record,
        address _writer,
        uint256 _marketerRate,
        address _council
    )
        public
        validAddress(_writer) validString(_record) validAddress(_council)
    {
        record = _record;
        writer = _writer;
        marketerRate = _marketerRate;
        council = ICouncil(_council);

        emit RegisterContent(msg.sender, "initializing content");
    }

    function updateContent(
        string _record,
        uint256 _marketerRate
    )
        external
        validAccessAddress(msg.sender)
    {
        record = _record;
        marketerRate = _marketerRate;

        emit ChangeContent(msg.sender, "update content");
    }

    function addEpisode(string _record, string _cuts, uint256 _price)
        external
        validAccessAddress(msg.sender)
    {
        episodes.push(Episode(_record, _cuts, _price, 0));

        emit RegisterEpisode(msg.sender, "add episode", (episodes.length.sub(1)));
    }

    function updateEpisode(uint256 _index, string _record, string _cuts, uint256 _price)
        external
        validAccessAddress(msg.sender)
    {
        episodes[_index].record = _record;
        episodes[_index].cuts = _cuts;
        episodes[_index].price = _price;

        emit ChangeEpisode(msg.sender, "update episode", _index);
    }

    function getRecord() public view returns (string record_) {
        record_ = record;
    }

    function getWriter() public view returns (address writer_) {
        writer_ =  writer;
    }

    function getMarketerRate() public view returns (uint256 marketerRate_) {
        marketerRate_ =  marketerRate;
    }

    function getEpisodeLength() public view returns (uint256 episodeLength_)
    {
        episodeLength_ = episodes.length;
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
        returns (bytes record_, uint256 price_, uint256 buyCount_, bool isPurchased_)
    {
        record_ = bytes(episodes[_index].record);
        price_ = episodes[_index].price;
        buyCount_ = episodes[_index].buyCount;
        isPurchased_ = episodes[_index].buyUser[_buyer];
    }

    function getEpisodeCuts(uint256 _index)
        external
        view
        returns (string episodeCuts_)
    {
        if(council.getApiContents() == msg.sender) {
            episodeCuts_ = episodes[_index].cuts;
        }
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

        emit EpisodePurchase(_buyer, _index);
    }
}
