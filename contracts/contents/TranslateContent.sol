pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/contents/Content.sol";
import "contracts/contents/TranslateEpisode.sol";
import "contracts/utils/ExtendsOwnable.sol";

contract TranslateContent is ExtendsOwnable {
    using SafeMath for uint256;

    string public title;
    address public writer;
    address public translator;
    string public synopsis;
    string public genres;
    string public languageName;
    Content public originContent;
    address[] public episodes;

    modifier contentOwner() {
        require(translator == msg.sender || owners[msg.sender]);
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
        address _translator,
        string _synopsis,
        string _genres,
        string _languageName,
        address _originContent
    )
        public
    {
        require(bytes(_title).length > 0 && bytes(_genres).length > 0 && bytes(_languageName).length > 0);
        require(_writer != address(0) && _writer != address(this));
        require(_translator != address(0) && _translator != address(this));
        require(_originContent != address(0) && _originContent != address(this));

        originContent = Content(_originContent);
        writer = originContent.writer();
        require(writer != address(0));

        title = _title;
        translator = _translator;
        synopsis = _synopsis;
        genres = _genres;
        languageName = _languageName;

        emit RegisterContents(msg.sender, "initializing translate content", languageName);
    }

    function updateContent(
        string _title,
        address _translator,
        string _synopsis,
        string _genres,
        string _languageName
    )
        external
        contentOwner validAddress(_translator) validString(_title)
        validString(_synopsis) validString(_genres) validString(_languageName)
    {
        title = _title;
        translator = _translator;
        synopsis = _synopsis;
        genres = _genres;
        languageName = _languageName;

        emit RegisterContents(msg.sender, "reset translate content", languageName);
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

    function addEpisode(address _episodeAddr)
        external
        contentOwner
    {
        episodes.push(Episode(_episodeAddr));
        emit RegisterContents(msg.sender, "episode");
    }

    function getTitleImage()
        public
        view
        returns (string)
    {
        return originContent.titleImage();
    }

    function getThumbnale()
        public
        view
        returns (string)
    {
        return originContent.thumbnail();
    }

    function getEpisodeList()
        public
        view
        returns (address[], string[], string[], uint256[])
    {
        uint256 arrayLength = episodes.length;
        address[] memory episodeAddress = new address[](arrayLength);
        string[] memory episodeTitles = new string[](arrayLength);
        string[] memory episodeTitleImages = new string[](arrayLength);
        uint256[] memory episodePrices = new uint256[](arrayLength);

        for(uint256 i = 0 ; i < arrayLength ; i++) {
            episodeAddress[i] = address(episodes[i]);
            episodeTitles[i] = episodes[i].title();
            episodeTitleImages[i] = episode[i].titleImage();
            episodePrices[i] = episode[i].price();
        }

        return (episodeAddress, episodeTitles, episodeTitleImages, episodePrices);
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


    event ChangeExternalAddress(address _addr, string _name);
    event ChangeContentDescription(address _addr, string _name);
    event RegisterContents(address _addr, string _name, string _languageName);
}
