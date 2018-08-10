pragma solidity ^0.4.24;

contract CustomToken {
    function approveAndCall(address _to, uint256 _value, address[] _address, uint256 _index) public returns (bool);
    event ApproveAndCall(address indexed _from, address indexed _to, uint256 _value);
}
