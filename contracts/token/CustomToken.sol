pragma solidity ^0.4.24;

contract CustomToken {
    function approveAndCall(address _to, uint256 _value, bytes _data) public returns (bool);
    function transferFromPxl(address _from, address _to, uint256 _value, string message) public returns (bool);
    function transferPxl(address _to, uint256 _value, string message) public returns (bool);
    event ApproveAndCall(address indexed _from, address indexed _to, uint256 _value, bytes _data);
    event PxlTransfer(address indexed _from, address indexed _to, uint256 _value, string _message, uint256 _time);
}
