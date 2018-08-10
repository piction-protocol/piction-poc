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

  modifier validRate(uint256 _rate) {
      uint256 validDecimals = 10 ** 16;
      require((_rate/validDecimals) > 0);
      require((_rate/validDecimals) <= 100);
      _;
  }
}
