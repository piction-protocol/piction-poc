pragma solidity ^0.4.24;

/**
 * @title Marketer contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Marketer {
  mapping (bytes => address) marketerInfo;

  modifier validAddress(address _account) {
      require(_account != address(0));
      require(_account != address(this));
      _;
  }

  function getMarketerKey() public validAddress(msg.sender) returns(bytes) {
      bytes key = bytes(keccak256(abi.encodePacked(msg.sender)));
      marketerInfo[key] = msg.sender;

      return key;
  }

  function getMarketerAddress(bytes _key) public validAddress(msg.sender) view returns(address) {
      return marketerInfo[_key];
  }
}
