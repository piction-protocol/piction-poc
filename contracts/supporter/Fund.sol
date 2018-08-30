pragma solidity ^0.4.24;

import "contracts/supporter/SupporterPool.sol";
import "contracts/council/CouncilInterface.sol";
import "contracts/supporter/FundInterface.sol";
import "contracts/token/ContractReceiver.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Fund is ContractReceiver, FundInterface, ExtendsOwnable, ValidValue {
	using Math for uint256;
	using SafeMath for uint256;
	using SafeERC20 for ERC20;
	using TimeLib for *;

	struct Supporter {
		address user;
		uint256 investment;
		uint256 collection;
		uint256 distributionRate;
	}

	uint256 decimals = 18;

	uint256 startTime;
	uint256 public endTime;
	string detail;

	address council;
	address content;
	address writer;

	uint256 fundRise;
	Supporter[] supporters;
	uint256 poolSize;
	uint256 releaseInterval;
	uint256 distributionRate;

	SupporterPool public supporterPool;

	constructor(
		address _council,
		address _content,
		address _writer,
		uint256 _startTime,
		uint256 _endTime,
		uint256 _poolSize,
		uint256 _releaseInterval,
		uint256 _distributionRate,
		string _detail)
	public validAddress(_content) validAddress(_writer) validAddress(_council) {
		require(_startTime > TimeLib.currentTime());
		require(_endTime > _startTime);
		require(_poolSize > 0);
		require(_releaseInterval > 0);
		require(distributionRate <= 10 ** decimals);

		council = _council;
		content = _content;
		writer = _writer;
		startTime = _startTime;
		endTime = _endTime;
		detail = _detail;
		poolSize = _poolSize;
		releaseInterval = _releaseInterval;
		distributionRate = _distributionRate;
	}

	function receiveApproval(address _from, uint256 _value, address _token, bytes _data) public validAddress(_from) validAddress(_token) {
		support(_from, _value, _token);
	}

	function support(address _from, uint256 _value, address _token) private {
		require(TimeLib.currentTime().between(startTime, endTime));

		ERC20 token = ERC20(CouncilInterface(council).getToken());
		require(address(token) == _token);

		(uint256 index, bool success) = findSupporterIndex(_from);
		if (success) {
			supporters[index].investment = supporters[index].investment.add(_value);
		} else {
			supporters.push(Supporter(_from, _value, 0, 0));
		}

		fundRise = fundRise.add(_value);
		token.safeTransferFrom(_from, address(this), _value);

		emit Support(_from, _value);
	}

	function createSupporterPool() external {
		require(address(supporterPool) == address(0));
		require(TimeLib.currentTime() > endTime);
		require(fundRise > 0);

		setDistributionRate();
		supporterPool = new SupporterPool(council, address(this), writer, fundRise, poolSize, releaseInterval);

		ERC20 token = ERC20(CouncilInterface(council).getToken());
		token.safeTransfer(supporterPool, fundRise);
	}

	function setDistributionRate() private {
		uint256 totalInvestment;
		for (uint256 i = 0; i < supporters.length; i++) {
			totalInvestment = totalInvestment.add(supporters[i].investment);
		}
		for (i = 0; i < supporters.length; i++) {
			supporters[i].distributionRate = (10 ** decimals).mul(supporters[i].investment).div(totalInvestment);
		}
	}

	function distribution(uint256 _total) external returns (address[], uint256[]) {
		address[] memory _supporters = new address[](supporters.length);
		uint256[] memory _amounts = new uint256[](supporters.length);

		for (uint256 i = 0; i < supporters.length; i++) {
			_supporters[i] = supporters[i].user;
			uint256 remain = supporters[i].investment.sub(supporters[i].collection);
			if (remain == 0) {
				_amounts[i] = _total.mul(distributionRate).div(10 ** decimals);
				_amounts[i] = _amounts[i].mul(supporters[i].distributionRate).div(10 ** decimals);
			} else {
				_amounts[i] = _total.mul(supporters[i].distributionRate).div(10 ** decimals).min256(remain);
				supporters[i].collection = supporters[i].collection.add(_amounts[i]);
			}
		}
		return (_supporters, _amounts);
	}

	function getSupporters() public view returns (address[], uint256[], uint256[], uint256[]) {
		address[] memory _user = new address[](supporters.length);
		uint256[] memory _investment = new uint256[](supporters.length);
		uint256[] memory _collection = new uint256[](supporters.length);
		uint256[] memory _distributionRate = new uint256[](supporters.length);

		for (uint256 i = 0; i < supporters.length; i++) {
			_user[i] = supporters[i].user;
			_investment[i] = supporters[i].investment;
			_collection[i] = supporters[i].collection;
			_distributionRate[i] = supporters[i].distributionRate;
		}
		return (_user, _investment, _collection, _distributionRate);
	}

	function getSupporterCount() public view returns (uint256) {
		return supporters.length;
	}

	function info() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, string, address){
		return (startTime, endTime, fundRise, poolSize, releaseInterval, distributionRate, detail, supporterPool);
	}


	function findSupporterIndex(address _supporter) private view returns (uint, bool){
		for (uint256 i = 0; i < supporters.length; i++) {
			if (supporters[i].user == _supporter) {
				return (i, true);
			}
		}
	}

	function isSupporter(address _supporter) public view returns (bool){
		for (uint256 i = 0; i < supporters.length; i++) {
			if (supporters[i].user == _supporter) {
				return true;
			}
		}
	}

	event Support(address _from, uint256 _amount);
}
