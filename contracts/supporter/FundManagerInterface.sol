pragma solidity ^0.4.24;

contract FundManagerInterface {

    function getFunds(address _content) external returns (address[]);

    function getDistributeAmount(address _fund, uint256 _total) external view returns (address[], uint256[]);

    function getSupportCount() public view returns (uint256);

}