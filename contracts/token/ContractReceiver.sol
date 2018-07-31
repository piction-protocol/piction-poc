pragma solidity ^0.4.24;

contract ContractReceiver {
    function receiveApproval(address _from, uint256 _value, address _token, string _data) public;
    function receiveApproval(address _from, uint256 _value, address _token, address _address) public;
    function receiveApproval(address _from, uint256 _value, address _token, uint256 _number) public;
    function receiveApproval(address _from, uint256 _value, address _token, bytes32 _bytes) public;
    function receiveApproval(address _from, uint256 _value, address _token, address _cd, address _content, uint256 _index, address _marketer) public;
}
