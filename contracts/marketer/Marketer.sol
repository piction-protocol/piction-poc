pragma solidity ^0.4.24;

/**
 * @title Marketer contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Marketer {
  mapping (bytes32 => address) marketerInfo;

  modifier validAddress(address _account) {
      require(_account != address(0));
      require(_account != address(this));
      _;
  }

  function getMarketerKey() public validAddress(msg.sender) returns(bytes32) {
      bytes32 key = bytes32(keccak256(abi.encodePacked(msg.sender)));
      marketerInfo[key] = msg.sender;

      return key;
  }

  function getMarketerAddress(bytes32 _key) public validAddress(msg.sender) view returns(address) {
      return marketerInfo[_key];
  }
}
