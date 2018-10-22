pragma solidity ^0.4.24;

interface IDepositPool {
    function reportReward(address _content, address _reporter, uint256 _type, string _descripstion) external returns(uint256 deduction_, bool contentBlock_);
    function getDeposit(address _content) external view returns(uint256 depositAmount_);
    function getReleaseDate(address _content) external view returns(uint256 releaseDate_);
}
