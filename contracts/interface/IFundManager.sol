pragma solidity ^0.4.24;

interface IFundManager {
    function createFund(
        address _content,
        uint256 _startTime,
        uint256 _endTime,
        uint256[] _limit,
        uint256 _poolSize,
        uint256 _releaseInterval,
        uint256 _supportFirstTime,
        uint256 _distributionRate,
        string _detail
    ) external returns (address fund_);

    function getFund(address _content) external view returns (address fund_);
    function distribution(address _fund, uint256 _total) external returns (address[] supporter_, uint256[] amount_);
}
