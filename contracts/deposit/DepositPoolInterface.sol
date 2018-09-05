pragma solidity ^0.4.24;

interface DepositPoolInterface {
    function reportReward(address _content, address _reporter) external returns(uint256);
}
