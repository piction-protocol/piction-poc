pragma solidity ^0.4.24;

import "contracts/marketer/MarketerInterface.sol";

/**
 * @title Marketer contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Marketer is MarketerInterface {
    mapping (bytes32 => address) marketerInfo;

    function generateMarketerKey() public returns(bytes32) {
        bytes32 key = bytes32(keccak256(abi.encodePacked(msg.sender)));
        return key;
    }

    function setMarketerKey(bytes32 _key) external {
        marketerInfo[_key] = msg.sender;
    }

    function getMarketerAddress(bytes32 _key) public view returns(address) {
        return marketerInfo[_key];
    }
}
