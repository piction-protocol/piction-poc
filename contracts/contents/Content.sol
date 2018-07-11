pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

//import "contracts/contents/Episode.sol";
//import "contracts/supporter/Fundraising.sol";
//import "contracts/supporter/Supporters.sol";
import "contracts/utils/ExtendsOwnable.sol";

contract Content is ExtendsOwnable {
    using SafeMath for uint256;

    string public name;
    address public writer;
    string public synopsis;
    string public genres;
    string public titleImage;
//    Fundraising public fundraising;
//    Supporters public supporters;
    uint256 public marketerRate;
    uint256 public translatorRate;
//    Episode[] public episodes;
//    TranslatorContent[] public translators;

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
        string _name,
        address _writer,
        string _synopsis,
        string _genres,
        string _titleImage,
        uint256 _marketerRate,
        uint256 _translatorRate
    ) public {
        require(bytes(_name).length > 0 && bytes(_titleImage).length > 0 && bytes(_genres).length > 0);
        require(_writer != address(0) && _writer != address(this));

        name = _name;
        writer = _writer;
        synopsis = _synopsis;
        genres = _genres;
        titleImage = _titleImage;
        marketerRate = _marketerRate;
        translatorRate = _translatorRate;

        emit RegisterContents(msg.sender, "initializing content");
    }

    function resetContent(
        string _name,
        address _writer,
        string _synopsis,
        string _genres,
        string _titleImage,
        uint256 _marketerRate,
        uint256 _translatorRate
    ) external contentOwner validAddress(_writer) {
        require(bytes(_name).length > 0 && bytes(_titleImage).length > 0 && bytes(_genres).length > 0);

        name = _name;
        writer = _writer;
        synopsis = _synopsis;
        genres = _genres;
        titleImage = _titleImage;
        marketerRate = _marketerRate;
        translatorRate = _translatorRate;

        emit RegisterContents(msg.sender, "reset content");
    }
/*
    function addSupporter(address _supporterAddr) external contentOwner validAddress(_supporterAddr) {
        supporters.push(Supporters(_supporterAddr));
        emit ChangeExternalAddress(_supporterAddr, "add supporter address");
    } */

    function setWriter(address _writerAddr) external contentOwner validAddress(_writerAddr) {
        writer = _writerAddr;
        emit ChangeExternalAddress(writer, "writer");
    }

    /* function setFundraising(address _funraisingAddr) external contentOwner validAddress(_writerAddr) {
        fundraising = Fundraising(_funraisingAddr);
        emit ChangeExternalAddress(_funraisingAddr, "fundraising");
    } */

    function setContentName(string _name) external contentOwner validString(_name) {
        name = _name;
        emit ChangeContentDescription(msg.sender, "content name");
    }

    function setSynopsis(string _synopsis) external contentOwner validString(_synopsis) {
        synopsis = _synopsis;
        emit ChangeContentDescription(msg.sender, "synopsis");
    }

    function setGenres(string _genres) external contentOwner validString(_genres) {
        genres = _genres;
        emit ChangeContentDescription(msg.sender, "genres");
    }

    function setTitleImage(string _imagePath) external contentOwner validString(_imagePath) {
        titleImage = _imagePath;
        emit ChangeContentDescription(msg.sender, "title image");
    }

    function setMarketerRate(uint256 _marketerRate) external contentOwner {
        marketerRate = _marketerRate;
        emit ChangeDistributionRate(msg.sender, "marketer rate");
    }

    function setTranslatorRate(uint256 _translatorRate) external contentOwner {
        translatorRate = _translatorRate;
        emit ChangeDistributionRate(msg.sender, "translator rate");
    }

    /* function addEpisode(address _episodeAddr) external contentOwner {
        episodes.push(Episode(_episodeAddr));
        emit RegisterContents(msg.sender, "episode");
    }

    function addTranslatorContent(address _translatorAddr) external contentOwner {
        translators.push(TranslatorContent(_translatorAddr));
        emit RegisterContents(msg.sender, "translator contents");
    }

    function getSupportersAddress() public view return (address) {
        return address(supporters);
    }

    function getEpisodeList() public view return (address[], string[], string[], uint256[]) {
        uint256 arrayLength = episodes.length;
        address[] memory episodeAddress = new address[](arrayLength);
        string[] memory episodeNames = new string[](arrayLength);
        string[] memory episodeTitleImages = new string[](arrayLength);
        uint256[] memory episodePrices = new uint256[](arrayLength);

        for(uint256 i = 0 ; i < arrayLength ; i++) {
            episodeAddress[i] = address(episodes[i]);
            episodeNames[i] = episodes[i].name();
            episodeTitleImages[i] = episode[i].titleImage();
            episodePrices[i] = episode[i].price();
        }

        return (episodeAddress, episodeNames, episodeTitleImages, episodePrices);
    }

    function getTranslationLanguageList() public view return (string[]) {
        string[] memory translationLanguages = new string[](translators.length);

        for(uint256 i = 0 ; i < translators.length ; i++) {
            translationLanguages[i] = translators[i].language;
        }

        return translationLanguages;
    } */

    event ChangeExternalAddress(address _addr, string _name);
    event ChangeDistributionRate(address _addr, string _name);
    event ChangeContentDescription(address _addr, string _name);
    event RegisterContents(address _addr, string _name);
}
