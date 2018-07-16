pragma solidity ^0.4.24;

import "contracts/utils/ExtendsOwnable.sol";

import "contracts/council/Council.sol";
import "contracts/contents/Content.sol";

contract ContentsManager is ExtendsOwnable {

    mapping (address => bool) isRegistered;

    address[] public cotentsAddress;
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
    {
        require(_councilAddr != address(0) && _councilAddr != address(this));

        council = _councilAddr;
    }

    function setCouncilAddress(address _councilAddr)
        external
        onlyOwner validAddress(_councilAddr)
    {
        council = _councilAddress;
        emit ChangeExternalAddress(msg.sender, "council");
    }

    function setChildContentsManagerAddress(uint256 _count, address _contentsMangerAddr)
        external
        onlyOwner validAddress(_contentsMangerAddr)
    {
        uint256 changeNumber;
        for(uint256 i = 0 ; i < cotentsAddress.length ; i++) {
            if(changeNumber < _count) {
                if(address(cotentsAddress[i].contentsManager()) != _contentsMangerAddr ) {
                    cotentsAddress[i].setContentsManager(_contentsMangerAddr);
                    changeNumber = changeNumber.add(1);
                }
            }
        }
    }

    function addContents(
        string _title,
        address _writer,
        string _synopsis,
        string _genres,
        string _thumbnail,
        string _titleImage,
        uint256 _marketerRate
    )
        external
        onlyOwner validString(_title) validAddress(_writer) validString(_synopsis)
        validString(_genres) validString(_thumbnail) validString(_titleImage)
    {
        Council council = Council(councilAddress);

        address contractAddress = new Content(
            _title, _writer, _synopsis, _genres, _thumbnail, _titleImage, _marketerRate, address(this));

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
        for(uint256 i = 0 ; i < cotentsAddress.length ; i++) {
            Content content = Content(cotentsAddress[i]);
            if (_writerAddr = content.writer()) {
                arrayLength = arrayLength.add(1);
            }
        }

        address[] memory addr = new address[](arrayLength);

        uint256 idx;
        for(uint256 i = 0 ; i < cotentsAddress.length ; i++) {
            Content content = Content(cotentsAddress[i]);
            if (_writerAddr = content.writer()) {
                addr[idx] = address(content);
                idx = idx.add(1);
            }
        }
        return addr;
    }

    event RegisterContents(address _contentAddress, uint256 _registerCount);
    event ChangeExternalAddress(address _addr, string _name);
}
