pragma solidity ^0.4.24;

import "contracts/utils/ValidValue.sol";

/**
 * @title Marketer contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Marketer is ValidValue {
  mapping (bytes32 => address) marketerInfo;

  function getMarketerKey() public validAddress(msg.sender) returns(bytes32) {
      bytes32 key = bytes32(keccak256(abi.encodePacked(msg.sender)));
      marketerInfo[key] = msg.sender;

      return key;
  }

  function getMarketerAddress(bytes32 _key) public validAddress(msg.sender) view returns(address) {
      return marketerInfo[_key];
  }
}
