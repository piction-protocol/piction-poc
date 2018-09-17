pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "contracts/interface/ICouncil.sol";

import "contracts/interface/IFund.sol";
import "contracts/utils/TimeLib.sol";

contract SupporterPool is Ownable {
	using SafeERC20 for ERC20;
	using SafeMath for uint256;
	using TimeLib for *;

	enum State {PENDING, PAID, CANCEL_PAYMENT}

	struct Distribution {
		uint256 amount;
		uint256 distributableTime;
		uint256 distributedTime;
		State state;
		uint256 votingCount;
		mapping(address => bool) voting;
	}

	Distribution[] distributions;
	address council;
	address writer;
	uint256 interval;
	IFund fundInterface;

	constructor(
		address _council,
		address _fundInterface,
		address _writer,
		uint256 _amount,
		uint256 _size,
		uint256 _interval)
	public {
		council = _council;
		fundInterface = IFund(_fundInterface);
		writer = _writer;
		interval = _interval;
		initialize(_amount, _size);
	}

	function initialize(uint256 _amount, uint256 _size) private {
		uint256 poolAmount = _amount.div(_size);
		for (uint256 i = 0; i < _size; i++) {
			addDistribution(poolAmount);
		}
		uint256 remainder = _amount.sub(poolAmount.mul(_size));
		if (remainder > 0) {
			distributions[distributions.length - 1].amount = distributions[distributions.length - 1].amount.add(remainder);
		}
	}

	function addDistribution(uint256 _amount) private {
		uint256 _distributableTime;
		if (distributions.length == 0) {
			_distributableTime = TimeLib.currentTime().add(interval);
		} else {
			_distributableTime = distributions[distributions.length - 1].distributableTime.add(interval);
		}
		distributions.push(Distribution(_amount, _distributableTime, 0, State.PENDING, 0));
	}

	function cancelDistribution(uint _index) private returns (uint256){
		require(distributions.length > _index);

		distributions[_index].state = State.CANCEL_PAYMENT;
		return distributions[_index].amount;
	}

	function distribution() external {
		ERC20 token = ERC20(ICouncil(council).getToken());
		for (uint256 i = 0; i < distributions.length; i++) {
			if (distributable(distributions[i])) {
				distributions[i].distributedTime = TimeLib.currentTime();
				distributions[i].state = State.PAID;
				token.safeTransfer(writer, distributions[i].amount);

				emit Release(distributions[i].amount);
			}
		}
	}

	function getDistributions() public view returns (uint256[], uint256[], uint256[], uint256[], uint256[], bool[]) {
		uint256[] memory _amount = new uint256[](distributions.length);
		uint256[] memory _distributableTime = new uint256[](distributions.length);
		uint256[] memory _distributedTime = new uint256[](distributions.length);
		uint256[] memory _state = new uint256[](distributions.length);
		uint256[] memory _votingCount = new uint256[](distributions.length);
		bool[] memory _isVoting = new bool[](distributions.length);

		for (uint256 i = 0; i < distributions.length; i++) {
			_amount[i] = distributions[i].amount;
			_distributableTime[i] = distributions[i].distributableTime;
			_distributedTime[i] = distributions[i].distributedTime;
			_state[i] = uint256(distributions[i].state);
			_votingCount[i] = distributions[i].votingCount;
			_isVoting[i] = isVoting(i);
		}
		return (_amount, _distributableTime, _distributedTime, _state, _votingCount, _isVoting);
	}

	function distributable(Distribution memory _distribution) private view returns (bool) {
		return _distribution.distributableTime <= TimeLib.currentTime() && _distribution.state == State.PENDING && _distribution.amount > 0;
	}

	function vote(uint256 _index) external returns (bool) {
		require(fundInterface.isSupporter(msg.sender));
		require(distributions.length > _index);
		require(distributions[_index].state == State.PENDING);
		uint256 votableTime = distributions[_index].distributableTime;
		require(TimeLib.currentTime().between(votableTime.sub(interval), votableTime));

		if (distributions[_index].voting[msg.sender]) {
			revert();
		} else {
			distributions[_index].voting[msg.sender] = true;
			distributions[_index].votingCount = distributions[_index].votingCount.add(1);
			if (fundInterface.getSupporterCount().mul(10 ** 18).div(2) <= distributions[_index].votingCount.mul(10 ** 18)) {
				uint256 cancelAmount = cancelDistribution(_index);
				addDistribution(cancelAmount);
			}
		}
	}

	function isVoting(uint256 _index) public view returns (bool){
		return distributions[_index].voting[msg.sender];
	}

	event Voting(address user, bool interrupt);
	event Release(uint256 amount);
}
