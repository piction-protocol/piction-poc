pragma solidity ^0.4.24;

import "contracts/contents/ContentInterface.sol";
import "contracts/supporter/FundManagerInterface.sol";
import "contracts/council/CouncilInterface.sol";
import "contracts/supporter/Fund.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";

contract FundManager is FundManagerInterface, ExtendsOwnable, ValidValue {
	using TimeLib for *;

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
		require(ContentInterface(_content).getWriter() == _writer);
		require(getLastFundedTime(_content) < TimeLib.currentTime());

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

	function getFunds(address _content) external view returns (address[]) {
		return funds[_content];
	}

	function getLastFundedTime(address _content) private view returns (uint256) {
		if (funds[_content].length > 0) {
			uint256 lastIndex = funds[_content].length - 1;
			return Fund(funds[_content][lastIndex]).endTime();
		} else {
			return 0;
		}
	}

	function distribution(address _fund, uint256 _total) external returns (address[], uint256[]) {
		require(
			msg.sender == CouncilInterface(council).getPixelDistributor()
			|| msg.sender == CouncilInterface(council).getDepositPool());

		return Fund(_fund).distribution(_total);
	}

	event RegisterFund(address _content, address _fund);
}
