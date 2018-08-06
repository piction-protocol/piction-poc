pragma solidity ^0.4.24;

import "contracts/utils/ExtendsOwnable.sol";
import "contracts/marketer/MarketerInterface.sol";
import "contracts/utils/ValidValue.sol";

/**
 * @title Marketer contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Marketer is ExtendsOwnable, MarketerInterface, ValidValue {
    mapping (bytes32 => address) marketerInfo;

    function generateMarketerKey() public returns(bytes32) {
        bytes32 key = bytes32(keccak256(abi.encodePacked(msg.sender)));
        return key;
    }

    function setMarketerKey(address _marketer, bytes32 _key) external onlyOwner validAddress(_marketer) {
        marketerInfo[_key] = _marketer;
    }

    function getMarketerAddress(bytes32 _key) public view returns(address) {
        return marketerInfo[_key];
    }
}
