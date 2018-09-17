pragma solidity ^0.4.24;

import "contracts/interface/IMarketer.sol";

/**
 * @title Marketer contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Marketer is IMarketer {
    mapping (bytes32 => address) marketerInfo;

    function generateMarketerKey() external returns(bytes32) {
        bytes32 key = bytes32(keccak256(abi.encodePacked(msg.sender)));
        return key;
    }

    function setMarketerKey(bytes32 _key) external {
        marketerInfo[_key] = msg.sender;
    }

    function getMarketerAddress(bytes32 _key) external view returns(address) {
        return marketerInfo[_key];
    }
}
