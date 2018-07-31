pragma solidity ^0.4.24;

contract MarketerInterface {
    function getMarketerKey() public returns(bytes32);
    function getMarketerAddress(bytes32 _key) public view returns(address);
}
