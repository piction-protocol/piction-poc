pragma solidity ^0.4.24;

interface DepositPoolInterface {
    function reportReward(address _content, address _reporter) external;
    function getContentDeposit(address _content) external view returns(uint256);
}
