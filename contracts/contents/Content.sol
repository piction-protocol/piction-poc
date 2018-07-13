pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/access/RoleManager.sol";
import "contracts/contents/Episode.sol";
import "contracts/contents/TranslateContent.sol";
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
    uint256 public translatorRate;
    address[] public episodes;
    address[] public translators;
    address public pxlToken;
    address public roleManager;

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
        uint256 _translatorRate,
        address _pxlToken,
        address _roleManager
    )
        public
    {
        require(bytes(_title).length > 0 && bytes(_titleImage).length > 0 &&
            bytes(_genres).length > 0 && bytes(_thumbnail).length > 0);
        require(_writer != address(0) && _writer != address(this));
        require(_pxlToken != address(0) && _pxlToken != address(this));
        require(_roleManager != address(0) && _roleManager != address(this));

        title = _title;
        writer = _writer;
        synopsis = _synopsis;
        genres = _genres;
        thumbnail = _thumbnail;
        titleImage = _titleImage;
        marketerRate = _marketerRate;
        translatorRate = _translatorRate;
        roleManager = _roleManager;

        emit RegisterContents(msg.sender, "initializing content");
    }

    function updateContent(
        string _title,
        address _writer,
        string _synopsis,
        string _genres,
        string _thumbnail,
        string _titleImage,
        uint256 _marketerRate,
        uint256 _translatorRate
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
        translatorRate = _translatorRate;

        emit RegisterContents(msg.sender, "reset content");
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

    function setTranslatorRate(uint256 _translatorRate)
        external
        contentOwner
    {
        translatorRate = _translatorRate;
        emit ChangeDistributionRate(msg.sender, "translator rate");
    }

    function addFund(
        uint256 _stripPeriod,
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
        address contractAddress = new Fund(
            writer, pxlToken, _stripPeriod, _maxcap, _softcap,
            _startTime, _endTime, _distributionRate, _imagePath, _description
        );

        fund.push(contractAddress);
        emit CreateContract(msg.sender, contractAddress, "fund");
    }

    function addEpisode(string _thumbnail, uint256 _price)
        external
        contentOwner validString(_thumbnail)
    {
        address contractAddress = new Episode(
            writer, _thumbnail, _price, address(this), roleManager);

        episodes.push(contractAddress);
        emit CreateContract(msg.sender, contractAddress, "episode");
    }

    function addTranslatorContent(address _translatorAddr, string _synopsis, string _genres, string _languageName)
        external
        contentOwner
        validAddress(_translatorAddr) validString(_synopsis) validString(_genres) validString(_languageName)
    {
        address contractAddress;
        contractAddress = new TranslateContent(
            writer, _translatorAddr, _synopsis, _genres, _languageName, address(this));

        translators.push(contractAddress);
        emit CreateContract(msg.sender, contractAddress, "translate contract");
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
            episodeAddress[i] = episodes[i];
            episodeTitles[i] = Episode(episodes[i]).title();
            episodeThumbnail[i] = Episode(episode[i]).titleImage();
            episodePrices[i] = Episode(episode[i]).price();
        }

        return (episodeAddress, episodeTitles, episodeThumbnail, episodePrices);
    }

    function getTranslationLanguageList()
        public
        view
        returns (string[], address[])
    {
        string[] memory translationLanguages = new string[](translators.length);
        address[] memory addr = new address[](translators.length);

        uint256 idx;
        for(uint256 i = 0 ; i < translators.length ; i++) {
            TranslateContent translateContent = TranslateContent(translators[i]);
            if(translateContent.episodes.length > 0) {
                addr[idx] = translators[i];
                translationLanguages[idx] = TranslateContent(translators[i]).language;
                idx = idx.add(1);
            }
        }
        return (translationLanguages, addr);
    }

    function getTotalPurchasedPxlAmount()
        public
        view
        returns (uint256)
    {
        uint256 amount;

        for(uint256 i = 0 ; i < episodes.length ; i++) {
            amount = amount.add(episodes.getPurchasedAmount());
        }

        return amount;
    }

    function getTranslatePurchasedPxlAmount()
        public
        view
        returns (uint256)
    {
        uint256 amount;
        for(uint256 i = 0 ; i < episodes.length ; i++) {
            amount = amount.add(episodes.getPurchasedAmount());
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

            uint256 idx;
            for(uint256 i = 0 ; i < fund.length ; i++) {
                address[] memory tempAddress = new address[](fund[i].supports().length);
                uint256[] memory tempAmount = new uint256[](fund[i].supports().length);

                (tempAddress, tempAmount) = fund[i].getDistributeAmount();

                for(uint256 j = 0 ; j < fund[i].supports().length ; j ++) {
                    supporter[idx] = tempAddress[j];
                    pxlAmount[idx] = tempAmount[j];
                }
            }
            return (supporter, pxlAmount);
        }
    }

    event ChangeExternalAddress(address _sender, string _name);
    event ChangeDistributionRate(address _sender, string _name);
    event ChangeContentDescription(address _sender, string _name);
    event RegisterContents(address _sender, string _name);
    event CreateContract(address _sender, address _contractAddr, string _contractName);
}
