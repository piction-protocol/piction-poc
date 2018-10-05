pragma solidity ^0.4.24;

interface IFund {
    function endFund() external;
    function getSupporters() external view returns (address[] memory user_, uint256[] memory investment_, uint256[] memory collection_, uint256[] memory distributionRate_, bool[] memory refund_);
    function info() external view returns (uint256 startTime_, uint256 endTime_, uint256 maxcap_, uint256 softcap_, uint256 fundRise_, uint256 poolSize_, uint256 releaseInterval, uint256 distributionRate, string detail);

	function getSupporterCount() external view returns (uint256);
	function isSupporter(address _supporter) external view returns (bool);
}
