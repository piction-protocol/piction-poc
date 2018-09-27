pragma solidity ^0.4.24;

interface ISupporterPool {
    function getDistributionsCount(address fund) external view returns(uint256 count_);
    function addSupport(address _fund, address _writer, uint256 _interval, uint256 _amount, uint256 _size) external;
}
