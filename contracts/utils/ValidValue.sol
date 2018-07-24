pragma solidity ^0.4.24;

contract ValidValue {
  modifier validRange(uint256 _value) {
      require(_value > 0);
      _;
  }

  modifier validAddress(address _account) {
      require(_account != address(0));
      require(_account != address(this));
      _;
  }

  modifier validString(string _str) {
      require(bytes(_str).length > 0);
      _;
  }
}
