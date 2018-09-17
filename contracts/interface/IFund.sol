pragma solidity ^0.4.24;

interface IFund {
    function getSupporters() external view returns (address[], uint256[], uint256[], uint256[]);
	function getSupporterCount() external view returns (uint256);
	function isSupporter(address _supporter) external view returns (bool);
	function info() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, string, address);
}
