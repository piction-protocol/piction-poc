pragma solidity ^0.4.23;

contract ContractReceiver {
    function receiveApproval(address _from, uint256 _value, address _token, bytes[] _extraData) public;
}
