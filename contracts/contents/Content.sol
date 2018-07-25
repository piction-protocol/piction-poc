pragma solidity ^0.4.24;

import "contracts/contents/Episode.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/ExtendsOwnable.sol";

contract Content is ExtendsOwnable, ValidValue {

    string public record;
    address public writer;
    uint256 public marketerRate;
    address[] public episodes;
    address public roleManager;

    modifier contentOwner() {
        require(writer == msg.sender || owners[msg.sender]);
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

        emit RegisterContents(msg.sender, "initializing content");
    }

    function updateContent(
        string _record,
        uint256 _marketerRate
    )
    external
    contentOwner validString(_record)
    {
        record = _record;
        marketerRate = _marketerRate;

        emit RegisterContents(msg.sender, "update content");
    }

    function addEpisode(string _record, uint256 _price)
    external
    contentOwner validString(_record)
    {
        address contractAddress = new Episode(
            _record, writer, _price, roleManager);

        episodes.push(contractAddress);
        emit CreateEpisode(msg.sender, contractAddress);
    }

    event RegisterContents(address _sender, string _name);
    event CreateEpisode(address _sender, address _contractAddr);
}
