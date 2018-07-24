pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/contents/Episode.sol";
import "contracts/council/Council.sol";
import "contracts/supporter/Fund.sol";
import "contracts/utils/ExtendsOwnable.sol";

contract Content is ExtendsOwnable {
    using SafeMath for uint256;

    string public title;
    address public writer;
    string public synopsis;
    string public genres;
    string public thumbnail;
    string public titleImage;
    address[] public fund;
    uint256 public marketerRate;
    address[] public episodes;
    Council public council;

    modifier contentOwner() {
        require(writer == msg.sender || owners[msg.sender]);
        _;
    }

    modifier validAddress(address _account) {
        require(_account != address(0));
        require(_account != address(this));
        _;
    }

    modifier validString(string _str) {
        require(bytes(_str).length > 0);
        _;
    }

    constructor(
        string _title,
        address _writer,
        string _synopsis,
        string _genres,
        uint256 _marketerRate,
        address _councilAddress
    )
    public
    validAddress(_writer) validString(_title) validString(_synopsis) validAddress(_councilAddress)
    {
        title = _title;
        writer = _writer;
        synopsis = _synopsis;
        genres = _genres;
        thumbnail = "empty";
        titleImage = "empty";
        marketerRate = _marketerRate;
        council = Council(_councilAddress);

        emit RegisterContents(msg.sender, "initializing content");
    }

    function updateContent(
        string _title,
        string _synopsis,
        string _genres,
        string _thumbnail,
        string _titleImage,
        uint256 _marketerRate
    )
    external
    contentOwner validString(_title) validString(_synopsis)
    validString(_titleImage) validString(_genres) validString(_thumbnail)
    {
        title = _title;
        synopsis = _synopsis;
        genres = _genres;
        thumbnail = _thumbnail;
        titleImage = _titleImage;
        marketerRate = _marketerRate;

        emit RegisterContents(msg.sender, "update content");
    }

    function setCouncil(address _councilAddress)
    external
    onlyOwner validAddress(_councilAddress)
    {
        council = Council(_councilAddress);
        emit ChangeExternalAddress(msg.sender, "council");
    }

    function setWriter(address _writerAddr)
    external
    contentOwner validAddress(_writerAddr)
    {
        writer = _writerAddr;
        emit ChangeExternalAddress(writer, "writer");
    }

    function addFund(
        uint256 _numberOfRelease,
        uint256 _maxcap,
        uint256 _softcap,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _distributionRate,
        string _imagePath,
        string _description
    )
    external
    contentOwner validString(_imagePath) validString(_description)
    {
        require(getDistributionRate().add(_distributionRate) > 100);

        address contractAddress = new Fund(
            address(this), writer, getCouncilAddress(), _numberOfRelease, _maxcap, _softcap,
            _startTime, _endTime, _distributionRate, _imagePath, _description);

        fund.push(contractAddress);
        emit CreateFund(msg.sender, contractAddress);
    }

    function addEpisode(string _title, string _thumbnail, uint256 _price)
    external
    contentOwner validString(_thumbnail) validString(_title)
    {
        address contractAddress = new Episode(
            _title, writer, _thumbnail, _price, getCouncilAddress());

        episodes.push(contractAddress);
        emit CreateEpisode(msg.sender, contractAddress);
    }

    function getPxlTokenAddress()
    public
    view
    returns (address)
    {
        return council.token();
    }

    function getRoleManagerAddress()
    public
    view
    returns (address)
    {
        return council.roleManager();
    }

    function getCouncilAddress()
    public
    view
    returns (address)
    {
        return address(council);
    }

    function getEpisodeAddress()
    public
    view
    returns (address[])
    {
        return episodes;
    }

    function getTotalPurchasedPxlAmount()
    public
    view
    returns (uint256)
    {
        uint256 amount;
        for (uint256 i = 0; i < episodes.length; i++) {
            amount = amount.add(Episode(episodes[i]).getPurchasedAmount());
        }
        return amount;
    }

    function isFunding()
    public
    view
    returns (bool)
    {
        return Fund(fund[fund.length - 1]).isOnFunding();
    }

    function getFundDistributeAmount(uint256 _amount)
    public
    view
    returns (address[], uint256[])
    {
        uint256 totalSupportCount = getTotalFundCount(funds);
        address[] memory supporters = new address[](totalSupportCount);
        uint256[] memory investedAmounts = new uint256[](totalSupportCount);

        uint256 idx;
        for (uint256 i = 0; i < funds.length; i++) {
            uint256 supportsCount = funds[i].supports().length;
            address[] memory _supporters = new address[](supportsCount);
            uint256[] memory _investedAmounts = new uint256[](supportsCount);

            (_supporters, _investedAmounts) = funds[i].getDistributeAmount();
            mergeFunds(idx, supporters, investedAmounts, _supporters, _investedAmounts);

            idx = idx.add(supportsCount);
        }

        return (supporters, investedAmounts);
    }

    function getTotalFundCount(Fund[] funds)
    private
    returns (uint256 totalSupportCount)
    {
        uint256 totalSupportCount;
        for (uint256 i = 0; i < funds.length; i++) {
            Fund fund = funds[i];
            totalSupportCount = arrayLength.add(fund.supports().length);
        }

        return totalSupportCount;
    }

    function mergeFunds(uint256 startIdx, address[] supporters, uint256[] investedAmounts, address[] _supporters, uint256[] _investedAmounts)
    private
    {
        uint idx = startIdx;
        for (uint256 i = 0; j < _supporters.length; i++) {
            supporters[idx] = _supporters[i];
            investedAmounts[idx] = _investedAmounts[i];
            idx = idx.add(1);
        }
    }

    function getDistributionRate()
    internal
    view
    returns (uint256)
    {
        uint256 returnRate;
        returnRate = returnRate.add(council.cdRate());
        returnRate = returnRate.add(council.depositRate());
        returnRate = returnRate.add(council.userPaybackRate());

        for (uint256 i = 0; i < fund.length; i++) {
            returnRate = returnRate.add(Fund(fund[i]).getDistributionRate());
        }
        return returnRate;
    }

    event RegisterContents(address _sender, string _name);
    event CreateFund(address _sender, address _contractAddr);
    event CreateEpisode(address _sender, address _contractAddr);
    event ChangeExternalAddress(address _sender, string _name);
}
