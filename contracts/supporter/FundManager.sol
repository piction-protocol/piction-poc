pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/supporter/FundManagerInterface.sol";
import "contracts/supporter/Fund.sol";
import "contracts/utils/ValidValue.sol";

contract FundManager is FundManagerInterface, ExtendsOwnable, ValidValue {
    using SafeMath for uint256;

    mapping(address => address[]) funds;
    address council;

    constructor(address _council) public validAddress(_council){
        council = _council;
    }

    function addFund(
        address _content,
        address _writer,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _poolSize,
        uint256 _releaseInterval,
        uint256 _distributionRate,
        string _detail)
    external {
        Fund fund = new Fund(
            council,
            _content,
            _writer,
            _startTime,
            _endTime,
            _poolSize,
            _releaseInterval,
            _distributionRate,
            _detail);

        funds[_content].push(fund);

        emit RegisterFund(_content, fund);
    }

    function getFunds(address _content) public returns (address[]) {
        return funds[_content];
    }

    function getDistributeAmount(address _fund, uint256 _total) public view returns (address[], uint256[]) {
        return Fund(_fund).getDistributeAmount(_total);
    }

    event RegisterFund(address _content, address _fund);
}