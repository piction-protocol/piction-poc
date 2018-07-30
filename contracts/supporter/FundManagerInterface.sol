pragma solidity ^0.4.24;

contract FundManagerInterface {

    function getFunds(address _content) external returns (address[]);

    function distribution(address _fund, uint256 _total) external returns (address[], uint256[]);

}