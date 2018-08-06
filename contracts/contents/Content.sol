pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/access/RoleManager.sol";
import "contracts/contents/ContentInterface.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/ExtendsOwnable.sol";

contract Content is ContentInterface, ExtendsOwnable, ValidValue {
    using SafeMath for uint256;

    struct Episode {
        string record;
        uint256 price;
        uint256 buyCount;
        mapping (address => bool) buyUser;
    }

    string public constant ROLE_NAME = "PXL_DISTRIBUTOR";

    address roleManager;
    string public record;
    address public writer;
    uint256 public marketerRate;
    Episode[] public episodes;

    modifier validEpisodeLength(uint256 _index) {
        require(episodes.length > _index);
        _;
    }

    constructor(
        string _record,
        address _writer,
        uint256 _marketerRate,
        address _roleManager
    )
    public
    validAddress(_writer) validString(_record) validAddress(_roleManager)
    {
        record = _record;
        writer = _writer;
        marketerRate = _marketerRate;
        roleManager = _roleManager;

        emit RegisterContent(msg.sender, "initializing content");
    }

    function updateContent(
        string _record,
        uint256 _marketerRate
    )
    external
    onlyOwner validString(_record)
    {
        record = _record;
        marketerRate = _marketerRate;

        emit ChangeContent(msg.sender, "update content");
    }

    function addEpisode(string _record, uint256 _price)
    external
    onlyOwner validString(_record)
    {
        episodes.push(Episode(_record, _price, 0));

        emit RegisterEpisode(msg.sender, "add episode", (episodes.length.sub(1)));
    }

    function updateEpisode(uint256 _index, string _record, uint256 _price)
    external
    onlyOwner validString(_record) validEpisodeLength(_index)
    {
        episodes[_index].record = _record;
        episodes[_index].price = _price;

        emit ChangeEpisode(msg.sender, "update episode", _index);
    }

    function isPurchasedEpisode(uint256 _index, address _buyer)
    public
    view
    returns (bool)
    {
        return episodes[_index].buyUser[_buyer];
    }

    function getRecord() public view returns (string) {
        return record;
    }

    function getWriter() public view returns (address) {
        return writer;
    }

    function getMarketerRate() public view returns (uint256) {
        return marketerRate;
    }

    function getEpisodeLength() public view returns (uint256)
    {
        return episodes.length;
    }

    function getEpisodeDetail(uint256 _index)
        public
        view
        returns (string, uint256, uint256)
    {
        require(msg.sender == writer || episodes[_index].buyUser[msg.sender]);
        return (episodes[_index].record, episodes[_index].price, episodes[_index].buyCount);
    }

    function episodePurchase(uint256 _index, address _buyer, uint256 _amount)
        external
        validAddress(_buyer) validEpisodeLength(_index)
    {
        require(RoleManager(roleManager).isAccess(msg.sender, ROLE_NAME));
        require(!episodes[_index].buyUser[_buyer]);
        require(episodes[_index].price == _amount);

        episodes[_index].buyUser[_buyer] = true;
        episodes[_index].buyCount = episodes[_index].buyCount.add(1);

        emit EpisodePurchase(_buyer, _index);
    }
}
