pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/council/Council.sol";
import "contracts/contents/Content.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/ExtendsOwnable.sol";

contract ContentsManager is ExtendsOwnable, ValidValue {
    using SafeMath for uint256;

    address[] public contentsAddress;
    address public council;

    constructor(address _councilAddr)
        public
        validAddress(_councilAddr)
    {
        council = _councilAddr;
    }

    function addContents(
        string _record,
        address _writer,
        uint256 _marketerRate
    )
        external
        onlyOwner validString(_record) validAddress(_writer)
    {
        address contractAddress = new Content(
            _record, _writer, _marketerRate, Council(council).roleManager());

        contentsAddress.push(contractAddress);

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
}
