pragma solidity ^0.4.24;

interface IFundManager {
    function addFund(address _content, address _writer, uint256 _startTime, uint256 _endTime, uint256 _poolSize, uint256 _releaseInterval, uint256 _distributionRate, string _detail) external;

    function getFunds(address _content) external view returns (address[] funds_);
    function distribution(address _fund, uint256 _total) external returns (address[], uint256[]);
}
