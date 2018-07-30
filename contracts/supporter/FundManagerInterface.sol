pragma solidity ^0.4.24;

contract FundManagerInterface {

    function getFunds(address _content) public returns (address[]);

    function getDistributeAmount(address _fund, uint256 _total) public view returns (address[], uint256[]);

}