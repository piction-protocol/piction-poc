pragma solidity ^0.4.24;

contract CustomToken {
    function approveAndCall(address _to, uint256 _value, bytes _data) public returns (bool);
    event ApproveAndCall(address indexed _from, address indexed _to, uint256 _value, bytes _data);
}
