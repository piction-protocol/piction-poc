pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/access/RoleManager.sol";
import "contracts/council/Council.sol";
import "contracts/utils/ExtendsOwnable.sol";

contract Episode is ExtendsOwnable {
    using SafeMath for uint256;

    string public constant ROLE_NAME = "episode_purchase_manager";

    mapping (address => bool) buyUser;


    string public title;
    address public writer;
    string public thumbnail;
    uint256 public price;
    string private jsonImages;
    uint256 public buyCount;
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
        string _thumbnail,
        uint256 _price,
        address _councilAddress
    )
        public
        validAddress(_writer) validString(_title)
        validString(_thumbnail) validAddress(_councilAddress)
    {
        title = _title;
        writer = _writer;
        thumbnail = _thumbnail;
        price = _price;
        council = Council(_councilAddress);

        emit RegisterContents(msg.sender, "initializing episode");
    }

    function updateEpisode(
        string _title,
        string _thumbnail,
        uint256 _price
    )
        external
        contentOwner
        validString(_title) validString(_thumbnail)
    {
        title = _title;
        thumbnail = _thumbnail;
        price = _price;

        emit RegisterContents(msg.sender, "update episode");
    }

    function setImages(string _jsonImages)
        external
        contentOwner
    {
        require(bytes(_jsonImages).length > 0);

        jsonImages = _jsonImages;
        emit SetEpisodeImages(msg.sender, jsonImages);
    }

    function getImages()
        external
        view
        returns (string)
    {
        require(getIsPurchased(msg.sender));

        return jsonImages;
    }

    function getPurchasedAmount()
        external
        view
        returns (uint256)
    {
        return buyCount.mul(price);
    }

    function getIsPurchased(address _buyer)
        public
        view
        returns (bool)
    {
        return buyUser[_buyer];
    }

    function episodePurchase(address _buyer, uint256 _amount)
        external
        validAddress(_buyer)
    {
        require(RoleManager(council.roleManager()).isAccess(msg.sender, ROLE_NAME));
        require(!buyUser[_buyer]);
        require(price == _amount);

        buyUser[_buyer] = true;
        buyCount = buyCount.add(1);

        emit EpisodePurchase(msg.sender, _buyer, title);
    }

    event RegisterContents(address _addr, string _name);
    event SetEpisodeImages(address _addr, string _jsonImages);
    event ChangeEpisodeImage(address _addr, uint256 _imageIndex);
    event ChangeExternalAddress(address _addr, string _name);
    event EpisodePurchase(address _sender, address _buyer, string _name);
}
