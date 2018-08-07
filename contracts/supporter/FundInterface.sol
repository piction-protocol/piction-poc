pragma solidity ^0.4.24;

contract FundInterface {

	function getSupporters() public view returns (address[], uint256[], uint256[], uint256[]);

	function getSupporterCount() public view returns (uint256);

	function isSupporter(address _supporter) public view returns (bool);

	function info() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, string, address);

}