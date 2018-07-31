pragma solidity ^0.4.24;

import "contracts/marketer/MarketerInterface.sol";
import "contracts/utils/ValidValue.sol";

/**
 * @title Marketer contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Marketer is MarketerInterface, ValidValue {
  mapping (bytes32 => address) marketerInfo;

  function getMarketerKey() public returns(bytes32) {
      bytes32 key = bytes32(keccak256(abi.encodePacked(msg.sender)));
      marketerInfo[key] = msg.sender;

      return key;
  }

  function getMarketerAddress(bytes32 _key) public view returns(address) {
      return marketerInfo[_key];
  }
}
