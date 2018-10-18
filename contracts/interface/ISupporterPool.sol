pragma solidity ^0.4.24;

interface ISupporterPool {
    function releaseDistribution(address _fund) external;
    function getDistributions(address _fund, address _sender) external view returns (uint256[] memory amount_, uint256[] memory distributableTime_, uint256[] memory distributedTime_, uint256[] memory state_, uint256[] memory votingCount_, bool[] memory isVoting_);
    function vote(address _fund, uint256 _index, address _sender) external;
    function isVoting(address _fund, uint256 _index, address _sender) external view returns (bool voting_);

    function getDistributionsCount(address _fund) external view returns(uint256 count_);
    function addSupport(address _fund, address _writer, uint256 _interval, uint256 _amount, uint256 _size, uint256 _supportFirstTime) external;
}
