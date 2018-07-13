pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/access/RoleManager.sol";
import "contracts/contents/Content.sol";
import "contracts/contents/Episode.sol";
import "contracts/contents/TranslateContent.sol";
import "contracts/utils/ExtendsOwnable.sol";

contract TranslateEpisode is ExtendsOwnable {
    using SafeMath for uint256;

    string public constant ROLE_NAME = "episode_purchase_manager";

    mapping (address => bool) buyUser;

    string public title;
    address public writer;
    address public translator;
    string public thumbnail;
    uint256 public price;
    string[] public url;
    uint256 public buyCount;
    Episode public originEpisode;
    TranslateContent public translateContent;
    RoleManager public roleManager;

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
        address _originEpisode,
        address _translateContent
    )
        public
    {
        require(bytes(_title).length > 0);
        require(_translator != address(0) && _translator != address(this));
        require(_originEpisode != address(0) && _originEpisode != address(this));
        require(_tranlateContent != address(0) && _tranlateContent != address(this));

        originEpisode = Episode(_originEpisode);
        writer = originEpisode.writer();
        roleManager = RoleManager(originEpisode.getRoleMansgerAddress());
        require(writer != address(0));

        title = _title;
        translator = _translator;
        thumbnail = originEpisode.thumbnail();
        price = originEpisode.price();
        translateContent = TranslateContent(_translateContent);
    }

    function setTitle(string _title)
        external
        contentOwner validString(_title)
    {
        title = _title;
        emit ChangeContentDescription(msg.sender, "episode title");
    }

    function setTranslator(address _translatorAddr)
        external
        contentOwner validAddress(_translatorAddr)
    {
        translator = _translatorAddr;
        emit ChangeExternalAddress(msg.sender, "translator");
    }

    function setUrls(string[] _urls)
        external
        contentOwner
    {
        require(_urls.length > 0);

        url = _url;
        emit ChangeContentDescription(msg.sender, "image urls");
    }

    function changeUrl(uint256 _idx, string _url)
        external
        contentOwner validString(_url)
    {
        require(url.length > _idx);

        url[_idx] = _url;
        emit ChangeContentDescription(msg.sender, "change image");
    }

    function setTranslateContentAddress(address _addr)
        external
        contentOwner validAddress(_addr)
    {
        translateContent = TranslateContent(_addr);
        emit ChangeExternalAddress(msg.sender, "Content");
    }

    function getPurchasedAmount()
        external
        view
        returns (uint256)
    {
        return buyCount.mul(price);
    }

    function getIsPurchased(address _buyer)
        external
        view
        returns (bool)
    {
        return buyUser[_buyer];
    }

    function episodePurchase(address _buyer)
        external
        validAddress(_buyer)
    {
        require(roleManager.isAccess(msg.sender, ROLE_NAME));
        require(!buyUser[_buyer]);

        buyUser[_buyer] = true;
        buyCount = buyCount.add(1);

        emit EpisodePurchase(msg.sender, _buyer, title);
    }

    event ChangeExternalAddress(address _addr, string _name);
    event ChangeDistributionRate(address _addr, uint256 _rate);
    event ChangeContentDescription(address _addr, string _name);
    event RegisterContents(address _addr, string _name);
    event EpisodePurchase(address _sender, address _buyer, string _name);
}
