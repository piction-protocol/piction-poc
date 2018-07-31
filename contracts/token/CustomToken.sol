pragma solidity ^0.4.24;

contract CustomToken {
    function approveAndCall(address _to, uint256 _value, string _data) public returns (bool);
    function approveAndCall(address _to, uint256 _value, address _address) public returns (bool);
    function approveAndCall(address _to, uint256 _value, uint256 _number) public returns (bool);
    function approveAndCall(address _to, uint256 _value, bytes32 _bytes) public returns (bool);
    function approveAndCall(address _to, uint256 _value, address _cd, address _content, uint256 _index, address _marketer) public returns (bool);
    event ApproveAndCall(address indexed _from, address indexed _to, uint256 _value, string _data);
    event ApproveAndCall(address indexed _from, address indexed _to, uint256 _value, address _address);
    event ApproveAndCall(address indexed _from, address indexed _to, uint256 _value, uint256 _number);
    event ApproveAndCall(address indexed _from, address indexed _to, uint256 _value, bytes32 _bytes);
    event ApproveAndCall(address indexed _from, address indexed _to, uint256 _value, address _cd, address _content, uint256 _index, address _marketer);
}
