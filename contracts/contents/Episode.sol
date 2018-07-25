pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/access/RoleManager.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/ExtendsOwnable.sol";

contract Episode is ExtendsOwnable, ValidValue {
    using SafeMath for uint256;

    string public constant ROLE_NAME = "episode_purchase_manager";

    mapping (address => bool) buyUser;

    string public record;
    address public writer;
    uint256 public price;
    uint256 public buyCount;
    address public content;
    address public roleManager;

    modifier contentOwner() {
        require(writer == msg.sender || owners[msg.sender]);
        _;
    }

    constructor(
        string _record,
        address _writer,
        uint256 _price,
        address _roleManager
    )
        public
        validAddress(_writer) validString(_record) validAddress(_roleManager)
    {
        record = _record;
        writer = _writer;
        price = _price;
        roleManager = _roleManager;

        emit RegisterContents(msg.sender, "initializing episode");
    }

    function updateEpisode(
        string _record,
        uint256 _price
    )
        external
        contentOwner validString(_record)
    {
        record = _record;
        price = _price;

        emit RegisterContents(msg.sender, "update episode");
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
        require(RoleManager(roleManager).isAccess(msg.sender, ROLE_NAME));
        require(!buyUser[_buyer]);
        require(price == _amount);

        buyUser[_buyer] = true;
        buyCount = buyCount.add(1);

        emit EpisodePurchase(msg.sender, _buyer);
    }

    event RegisterContents(address _addr, string _name);
    event EpisodePurchase(address _sender, address _buyer);
}
