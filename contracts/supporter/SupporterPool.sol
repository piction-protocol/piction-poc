pragma solidity ^0.4.24;

import "contracts/council/CouncilInterface.sol";
import "contracts/utils/TimeLib.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

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
		mapping(address => bool) voting;
	}

	Distribution[] distributions;
	address council;
	address writer;
	uint256 interval;

	constructor(
		address _council,
		address _writer,
		uint256 _amount,
		uint256 _size,
		uint256 _interval)
	public {
		council = _council;
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

	function addDistribution(uint256 _amount) public onlyOwner {
		uint256 _distributableTime;
		if (distributions.length == 0) {
			_distributableTime = TimeLib.currentTime().add(interval);
		} else {
			_distributableTime = distributions[distributions.length - 1].distributableTime.add(interval);
		}
		distributions.push(Distribution(_amount, _distributableTime, 0, State.PENDING));
	}

	function cancelDistribution() external onlyOwner returns (uint){
		(uint256 index, bool success) = getCurrentIndex();
		if (success) {
			distributions[index].state = State.CANCEL_PAYMENT;
			return distributions[index].amount;
		}
	}

	function distribution() external {
		ERC20 token = ERC20(CouncilInterface(council).getToken());
		for (uint256 i = 0; i < distributions.length; i++) {
			if (distributable(distributions[i])) {
				distributions[i].distributedTime = TimeLib.currentTime();
				distributions[i].state = State.PAID;
				token.safeTransfer(writer, distributions[i].amount);

				emit Release(distributions[i].amount);
			}
		}
	}

	function getDistributions() public view returns (uint256[], uint256[], uint256[], uint256[]) {
		uint256[] memory _amount = new uint256[](distributions.length);
		uint256[] memory _distributableTime = new uint256[](distributions.length);
		uint256[] memory _distributedTime = new uint256[](distributions.length);
		uint256[] memory _state = new uint256[](distributions.length);

		for (uint256 i = 0; i < distributions.length; i++) {
			_amount[i] = distributions[i].amount;
			_distributableTime[i] = distributions[i].distributableTime;
			_distributedTime[i] = distributions[i].distributedTime;
			_state[i] = uint256(distributions[i].state);
		}
		return (_amount, _distributableTime, _distributedTime, _state);
	}

	function getCurrentIndex() private view returns (uint, bool){
		for (uint256 i = 0; i < distributions.length; i++) {
			uint256 startTime = distributions[i].distributableTime;
			uint256 endTime = distributions[i].distributableTime.sub(interval);
			if (TimeLib.currentTime().between(startTime, endTime)) {
				return (i, true);
			}
		}
	}

	function distributable(Distribution memory _distribution) private view returns (bool) {
		return _distribution.distributableTime <= TimeLib.currentTime() && _distribution.state == State.PENDING && _distribution.amount > 0;
	}

	function vote(address _user) external onlyOwner {
		(uint256 index, bool success) = getCurrentIndex();
		if (success) {
			distributions[index].voting[_user] = true;
		}
	}

	function getVotingCount(address[] _users) public view returns (uint256 _count) {
		(uint256 index, bool success) = getCurrentIndex();
		if (success) {
			for (uint256 i = 0; i < _users.length; i++) {
				_count.add(isVoting(index, _users[i]));
			}
		}
	}

	function isVoting(uint256 poolIndex, address _user) private view returns (uint){
		return distributions[poolIndex].voting[_user] ? 1 : 0;
	}

	event Voting(address user, bool interrupt);
	event Release(uint256 amount);
}