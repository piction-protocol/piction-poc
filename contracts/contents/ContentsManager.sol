pragma solidity ^0.4.24;

import "contracts/utils/ExtendsOwnable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/council/Council.sol";
import "contracts/contents/Content.sol";

contract ContentsManager is ExtendsOwnable {
    using SafeMath for uint256;

    mapping (address => bool) isRegistered;

    address[] public contentsAddress;
    address public council;

    modifier validAddress(address _account) {
        require(_account != address(0));
        require(_account != address(this));
        _;
    }

    modifier validString(string _str) {
        require(bytes(_str).length > 0);
        _;
    }

    constructor(address _councilAddr)
        public
        validAddress(_councilAddr)
    {
        council = _councilAddr;
    }

    function setCouncilAddress(address _councilAddr)
        external
        onlyOwner validAddress(_councilAddr)
    {
        council = _councilAddr;
        emit ChangeExternalAddress(msg.sender, "council");
    }

    function addContents(
        string _title,
        address _writer,
        string _synopsis,
        string _genres,
        uint256 _marketerRate
    )
        external
        onlyOwner validString(_title) validAddress(_writer) validString(_synopsis) validString(_genres) 
    {
        address contractAddress = new Content(
            _title, _writer, _synopsis, _genres, _marketerRate, council);

        contentsAddress.push(contractAddress);
        isRegistered[contractAddress] = true;

        emit RegisterContents(contractAddress, contentsAddress.length);
    }

    function getWriterContents(address _writerAddr)
        external
        view
        returns (address[])
    {
        uint256 arrayLength;
        for(uint256 i = 0 ; i < contentsAddress.length ; i++) {
            Content contentA = Content(contentsAddress[i]);
            if (contentA.writer() == _writerAddr) {
                arrayLength = arrayLength.add(1);
            }
        }

        address[] memory addr = new address[](arrayLength);

        uint256 idx;
        for(uint256 j = 0 ; j < contentsAddress.length ; j++) {
            Content contentB = Content(contentsAddress[j]);
            if (contentB.writer() == _writerAddr) {
                addr[idx] = address(contentB);
                idx = idx.add(1);
            }
        }
        return addr;
    }

    event RegisterContents(address _contentAddress, uint256 _registerCount);
    event ChangeExternalAddress(address _addr, string _name);
}
