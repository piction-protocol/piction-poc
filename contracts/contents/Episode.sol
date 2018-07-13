pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/access/RoleManager.sol";
import "contracts/contents/Content.sol";
import "contracts/utils/ExtendsOwnable.sol";

contract Episode is ExtendsOwnable {
    using SafeMath for uint256;

    string public constant ROLE_NAME = "episode_purchase_manager";

    mapping (address => bool) buyUser;

    string public title;
    address public writer;
    string public thumbnail;
    uint256 public price;
    string[] public url;
    uint256 public buyCount;
    Content public content;
    RoleManager public roleManager;

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
        string _thumbnail,
        uint256 _price,
        address _contentAddress,
        address _roleManager
    ) public {
        require(bytes(_title).length > 0 && bytes(_thumbnail).length > 0);
        require(_writer != address(0) && _writer != address(this));
        require(_contentAddress != address(0) && _contentAddress != address(this));
        require(_roleManager != address(0) && _roleManager != address(this));

        content = Content(_contentAddress);
        require(content.writer() == _writer);

        title = _title;
        writer = _writer;
        thumbnail = _thumbnail;
        price = _price;
        roleManager = RoleManager(_roleManager);

        emit RegisterContents(msg.sender, "initializing episode");
    }

    function updateEpisode(
        string _title,
        address _writer,
        string _thumbnail,
        uint256 _price
    )
        external
        contentOwner
        validString(_title) validAddress(_writer) validString(_thumbnail)
    {
        require(content.writer() == _writer);

        title = _title;
        writer = _writer;
        thumbnail = _thumbnail;
        price = _price;

        emit RegisterContents(msg.sender, "update episode");
    }

    function setTitle(string _title)
        external
        contentOwner validString(_title)
    {
        title = _title;
        emit ChangeContentDescription(msg.sender, "episode title");
    }

    function setWriter(address _writerAddr)
        external
        contentOwner validAddress(_writerAddr)
    {
        writer = _writerAddr;
        emit ChangeExternalAddress(msg.sender, "writer");
    }

    function setThumbnail(string _imagePath)
        external
        contentOwner validString(_imagePath)
    {
        thumbnail = _imagePath;
        emit ChangeContentDescription(msg.sender, "title image");
    }

    function setPrice(uint256 _price)
        external
        contentOwner
    {
        price = _price;
        emit ChangeContentDescription(msg.sender, "price");
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

    function setContentAddress(address _addr)
        external
        contentOwner validAddress(_addr)
    {
        content = Content(_addr);
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

    function getRoleMansgerAddress()
        external
        view
        return (address)
    {
        return address(roleManager);
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
