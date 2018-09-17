pragma solidity ^0.4.24;

interface IMarketer {
    function generateMarketerKey() external returns(bytes32);
    function setMarketerKey(bytes32 _key) external;
    function getMarketerAddress(bytes32 _key) external view returns(address);
}
