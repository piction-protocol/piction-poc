pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/access/RoleManager.sol";
import "contracts/contents/Episode.sol";
import "contracts/contents/ContentsManager.sol";
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
    ContentsManager public contentsManager;

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
        string _thumbnail,
        string _titleImage,
        uint256 _marketerRate,
        address _contentsManager
    )
        public
    {
        require(bytes(_title).length > 0 && bytes(_titleImage).length > 0 &&
            bytes(_genres).length > 0 && bytes(_thumbnail).length > 0);
        require(_writer != address(0) && _writer != address(this));
        require(_contentsManager != address(0) && _contentsManager != address(this));

        title = _title;
        writer = _writer;
        synopsis = _synopsis;
        genres = _genres;
        thumbnail = _thumbnail;
        titleImage = _titleImage;
        contentsManager = ContentsManager(_contentsManager);

        emit RegisterContents(msg.sender, "initializing content");
    }

    function updateContent(
        string _title,
        address _writer,
        string _synopsis,
        string _genres,
        string _thumbnail,
        string _titleImage,
        uint256 _marketerRate
    )
        external
        contentOwner validAddress(_writer) validString(_title)
        validString(_titleImage) validString(_genres) validString(_thumbnail)
    {
        title = _title;
        writer = _writer;
        synopsis = _synopsis;
        genres = _genres;
        thumbnail = _thumbnail;
        titleImage = _titleImage;
        marketerRate = _marketerRate;

        emit RegisterContents(msg.sender, "reset content");
    }

    function setContentsManager(address _contentsManagerAddr)
        external
        onlyOwner validAddress(_contentsManagerAddr)
    {
        contentsManager = ContentsManager(_contentsManagerAddr);
        emit ChangeExternalAddress(msg.sender, "contents manager");
    }

    function setWriter(address _writerAddr)
        external
        contentOwner validAddress(_writerAddr)
    {
        writer = _writerAddr;
        emit ChangeExternalAddress(writer, "writer");
    }

    function setContentTitle(string _title)
        external
        contentOwner validString(_title)
    {
        title = _title;
        emit ChangeContentDescription(msg.sender, "content title");
    }

    function setSynopsis(string _synopsis)
        external
        contentOwner validString(_synopsis)
    {
        synopsis = _synopsis;
        emit ChangeContentDescription(msg.sender, "synopsis");
    }

    function setGenres(string _genres)
        external
        contentOwner validString(_genres)
    {
        genres = _genres;
        emit ChangeContentDescription(msg.sender, "genres");
    }

    function setTitleImage(string _imagePath)
        external
        contentOwner
        validString(_imagePath)
    {
        titleImage = _imagePath;
        emit ChangeContentDescription(msg.sender, "title image");
    }

    function setThumbnail(string _imagePath)
        external
        contentOwner
        validString(_thumbnail)
    {
        thumbnail = _imagePath;
        emit ChangeContentDescription(msg.sender, "thumbnail");
    }

    function setMarketerRate(uint256 _marketerRate)
        external
        contentOwner
    {
        marketerRate = _marketerRate;
        emit ChangeDistributionRate(msg.sender, "marketer rate");
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
            address(this), writer, getPxlTokenAddress(), _numberOfRelease, _maxcap, _softcap,
            _startTime, _endTime, _distributionRate, _imagePath, _description);

        fund.push(contractAddress);
        emit CreateContract(msg.sender, contractAddress, "fund");
    }

    function addEpisode(string _thumbnail, uint256 _price)
        external
        contentOwner validString(_thumbnail)
    {
        address contractAddress = new Episode(
            writer, _thumbnail, _price, address(this), getRoleManagerAddress());

        episodes.push(contractAddress);
        emit CreateContract(msg.sender, contractAddress, "episode");
    }

    function getPxlTokenAddress()
        public
        view
        returns (address)
    {
        return contentsManager.pxlToken();
    }

    function getRoleManagerAddress()
        public
        view
        returns (address)
    {
        return contentsManager.roleManager();
    }

    function getCouncilAddress()
        public
        view
        returns (address)
    {
        return contentsManager.council();
    }

    function getEpisodeDetail()
        public
        view
        returns (address[], string[], string[], uint256[])
    {
        uint256 arrayLength = episodes.length;
        address[] memory episodeAddress = new address[](arrayLength);
        string[] memory episodeTitles = new string[](arrayLength);
        string[] memory episodeThumbnail = new string[](arrayLength);
        uint256[] memory episodePrices = new uint256[](arrayLength);

        for(uint256 i = 0 ; i < arrayLength ; i++) {
            Episode episode = Episode(episodes[i]);
            episodeAddress[i] = address(episode);
            episodeTitles[i] = episode.title();
            episodeThumbnail[i] = episode.titleImage();
            episodePrices[i] = episode.price();
        }

        return (episodeAddress, episodeTitles, episodeThumbnail, episodePrices);
    }

    function getTotalPurchasedPxlAmount()
        public
        view
        returns (uint256)
    {
        uint256 amount;
        for(uint256 i = 0 ; i < episodes.length ; i++) {
            amount = amount.add(episodes[i].getPurchasedAmount());
        }
        return amount;
    }

    function isFunding()
        public
        view
        returns (bool)
    {
        return fund[fund.length - 1].isOnFunding();
    }

    function getFundDistributeAmount()
        public
        view
        returns (address[], uint256[])
    {
        if(fund.length == 0) {
            return (new address[](0), new uint256[](0));
        } else {
            uint256 arrayLength;
            for(uint256 i = 0 ; i < fund.length ; i++) {
                arrayLength = arrayLength.add(fund[i].supports().length);
            }

            address[] memory supporter = new address[](arrayLength);
            uint256[] memory pxlAmount = new uint256[](arrayLength);


            for(uint256 i = 0 ; i < fund.length ; i++) {
                address[] memory tempAddress = new address[](fund[i].supports().length);
                uint256[] memory tempAmount = new uint256[](fund[i].supports().length);

                (tempAddress, tempAmount) = fund[i].getDistributeAmount();

                uint256 idx;
                for(uint256 j = 0 ; j < fund[i].supports().length ; j ++) {
                    supporter[idx] = tempAddress[j];
                    pxlAmount[idx] = tempAmount[j];
                    idx = idx.add(1);
                }
            }
            return (supporter, pxlAmount);
        }
    }

    function getDistributionRate()
        internal
        view
        returns (uint256)
    {
        Council council = Council(contentsManager.council());

        uint256 returnRate;
        returnRate = returnRate.add(council.cdRate());
        returnRate = returnRate.add(council.deposit());
        returnRate = returnRate.add(council.userPaybackRate());

        for(uint256 i = 0 ; i < fund.length ; i++){
            returnRate = returnRate.add(fund[i].distributionRate());
        }
        return returnRate;
    }

    event ChangeExternalAddress(address _sender, string _name);
    event ChangeDistributionRate(address _sender, string _name);
    event ChangeContentDescription(address _sender, string _name);
    event RegisterContents(address _sender, string _name);
    event CreateContract(address _sender, address _contractAddr, string _contractName);
}
