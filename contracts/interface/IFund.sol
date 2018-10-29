pragma solidity ^0.4.24;

interface IFund {
    function endFund() public;
    function getSupporters() external view returns (address[] memory user_, uint256[] memory investment_, uint256[] memory collection_, uint256[] memory reward_, uint256[] memory distributionRate_, bool[] memory refund_);
    function getFundInfo() external view returns (address content_, uint256 startTime_, uint256 endTime_, uint256[] memory limit_, uint256 fundRise_, uint256 poolSize_, uint256 releaseInterval, uint256 distributionRate, uint256 supportFirstTime_, bool needEndProcessing_, string detail);

	function getSupporterCount() external view returns (uint256);
	function isSupporter(address _supporter) external view returns (bool);
}
