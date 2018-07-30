pragma solidity ^0.4.24;

import "contracts/supporter/FundManagerInterface.sol";
import "contracts/supporter/Fund.sol";
import "contracts/utils/ValidValue.sol";

contract FundManager is FundManagerInterface, ExtendsOwnable, ValidValue {

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
        // TODO: 콘텐츠 작성자인지 확인 필요
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

    function getFunds(address _content) external returns (address[]) {
        return funds[_content];
    }

    // TODO: pixelDistributor 권한 체크 해야 함
    function distribution(address _fund, uint256 _total) external returns (address[], uint256[]) {
        return Fund(_fund).distribution(_total);
    }

    function getSupportCount(address _fund) external view returns (uint256) {
        return Fund(_fund).getSupportCount();
    }

    event RegisterFund(address _content, address _fund);
}