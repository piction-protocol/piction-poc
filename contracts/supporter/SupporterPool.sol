pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IFund.sol";
import "contracts/interface/ISupporterPool.sol";

import "contracts/utils/TimeLib.sol";

contract SupporterPool is Ownable, ISupporterPool {
    using SafeERC20 for ERC20;
	using SafeMath for uint256;
	using TimeLib for *;

    enum State {PENDING, PAID, CANCEL_PAYMENT}

    struct Distribution {
        address fund;
        address writer;
        uint256 interval;
		uint256 amount;
		uint256 distributableTime;
		uint256 distributedTime;
		State state;
		uint256 votingCount;
		mapping(address => bool) voting;

	}

    mapping(address => Distribution[]) funds;

    ICouncil council;

    constructor(address _council) public {
		council = ICouncil(_council);
	}

    function addSupport(
        address _fund,
        address _writer,
        uint256 _interval,
        uint256 _amount,
        uint256 _size)
        external
    {
        //todo 접근제한 필요
        uint256 poolAmount = _amount.div(_size);
        for (uint256 i = 0; i < _size; i++) {
            addDistribution(_fund, _writer, _interval, _amount);
        }

        uint256 remainder = _amount.sub(poolAmount.mul(_size));
		if (remainder > 0) {
			funds[_fund][funds[_fund].length - 1].amount = funds[_fund][funds[_fund].length - 1].amount.add(remainder);
		}
    }

    function addDistribution(
        address _fund,
        address _writer,
        uint256 _interval,
        uint256 _amount)
        private
    {
		uint256 _distributableTime;
        if (funds[_fund].length == 0) {
            _distributableTime = TimeLib.currentTime().add(_interval);
        } else {
            _distributableTime = funds[_fund][funds[_fund].length - 1].distributableTime.add(_interval);
        }
        funds[_fund].push(Distribution(_fund, _writer, _interval, _amount, _distributableTime, 0, State.PENDING, 0));
	}

    function getDistributions(address fund, address sender)
        public
        view
        returns (
            uint256[] memory amount_,
            uint256[] memory distributableTime_,
            uint256[] memory distributedTime_,
            uint256[] memory state_,
            uint256[] memory votingCount_,
            bool[] memory isVoting_)
    {
		amount_ = new uint256[](funds[fund].length);
		distributableTime_ = new uint256[](funds[fund].length);
		distributedTime_ = new uint256[](funds[fund].length);
		state_ = new uint256[](funds[fund].length);
		votingCount_ = new uint256[](funds[fund].length);
		isVoting_ = new bool[](funds[fund].length);

		for (uint256 i = 0; i < funds[fund].length; i++) {
			amount_[i] = funds[fund][i].amount;
			distributableTime_[i] = funds[fund][i].distributableTime;
			distributedTime_[i] = funds[fund][i].distributedTime;
			state_[i] = uint256(funds[fund][i].state);
			votingCount_[i] = funds[fund][i].votingCount;
			isVoting_[i] = isVoting(fund, i, sender);
		}
	}

    function getDistributionsCount(address fund) external view returns(uint256 count_) {
        count_ = funds[fund].length;
    }

    function isVoting(address fund, uint256 _index, address sender) public view returns (bool){
		return funds[fund][_index].voting[sender];
	}

    function vote(address fund, uint256 _index, address sender) external returns (bool) {
		require(IFund(fund).isSupporter(sender));
		require(funds[fund].length > _index);
		require(funds[fund][_index].state == State.PENDING);
		uint256 votableTime = funds[fund][_index].distributableTime;
		require(TimeLib.currentTime().between(votableTime.sub(funds[fund][_index].interval), votableTime));

		if (funds[fund][_index].voting[sender]) {
			revert();
		} else {
			funds[fund][_index].voting[sender] = true;
			funds[fund][_index].votingCount = funds[fund][_index].votingCount.add(1);
			if (IFund(fund).getSupporterCount().mul(10 ** 18).div(2) <= funds[fund][_index].votingCount.mul(10 ** 18)) {
                funds[fund][_index].state = State.CANCEL_PAYMENT;
				addDistribution(
                    funds[fund][_index].fund,
                    funds[fund][_index].writer,
                    funds[fund][_index].interval,
                    funds[fund][_index].amount);
			}
		}
	}

    function distribution(address fund) external {
        ERC20 token = ERC20(ICouncil(council).getToken());
        for (uint256 i = 0; i < funds[fund].length; i++) {
            if (distributable(funds[fund][i])) {
                funds[fund][i].distributedTime = TimeLib.currentTime();
                funds[fund][i].state = State.PAID;
                token.safeTransfer(funds[fund][i].writer, funds[fund][i].amount);

                emit Release(funds[fund][i].amount);
            }
        }
    }

    function distributable(Distribution memory _distribution) private view returns (bool) {
		return _distribution.distributableTime <= TimeLib.currentTime() && _distribution.state == State.PENDING && _distribution.amount > 0;
	}

	event Release(uint256 amount);
}
