pragma solidity ^0.4.24;

import "contracts/utils/ExtendsOwnable.sol";

import "contracts/council/Council.sol";
import "contracts/contents/Content.sol";

contract ContentsManager is ExtendsOwnable {

    mapping (address => bool) isRegistered;

    address[] public cotentsAddress;
    address public councilAddress;

    modifier validAddress(address _account) {
        require(_account != address(0));
        require(_account != address(this));
        _;
    }

    constructor(address _councilAddr) {
        require(_councilAddr != address(0));
        require(_councilAddr != address(this));

        councilAddress = _councilAddr;
    }

    function setCouncilAddress(address _councilAddr)
        external
        onlyOwner validAddress(_councilAddr)
    {
        councilAddress = _councilAddress;
        emit ChangeExternalAddress(msg.sender, "council");
    }

    function addContents(address _contentAddress)
        external
        onlyOwner validAddress(_contentsAddress)
    {
        require(!isRegistered[_contentAddress]);

        Council council = Council(councilAddress);

        address contractAddress = new Content(
            _title, _writer, _synopsis, _genres, _thumbnail, _titleImage,
            _marketerRate, _translatorRate, council.token(), council.roleManager());

        contentsAddress.push(contractAddress);
        isRegistered[contractAddress] = true;

        emit RegisterContents(contractAddress, contentsAddress.length);
    }

    function getRegisteredContents()
        external
        view
        returns (address[])
    {
        address[] memory addr = new address[](cotentsAddress.length);

        uint256 idx;
        for(uint256 i = 0 ; i < cotentsAddress.length ; i++) {
            Content content = Content(cotentsAddress[i]);
            if (_addr = content.writer()) {
                addr[idx] = address(content);
                idx.add(1);
            }
        }
        return addr;
    }

    event RegisterContents(address _contentAddress, uint256 _registerCount);
    event ChangeExternalAddress(address _addr, string _name);
}
