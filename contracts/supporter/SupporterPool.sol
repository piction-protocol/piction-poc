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
        require(_fund == msg.sender);

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

    function getDistributions(address _fund, address _sender)
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
		amount_ = new uint256[](funds[_fund].length);
		distributableTime_ = new uint256[](funds[_fund].length);
		distributedTime_ = new uint256[](funds[_fund].length);
		state_ = new uint256[](funds[_fund].length);
		votingCount_ = new uint256[](funds[_fund].length);
		isVoting_ = new bool[](funds[_fund].length);

		for (uint256 i = 0; i < funds[_fund].length; i++) {
			amount_[i] = funds[_fund][i].amount;
			distributableTime_[i] = funds[_fund][i].distributableTime;
			distributedTime_[i] = funds[_fund][i].distributedTime;
			state_[i] = uint256(funds[_fund][i].state);
			votingCount_[i] = funds[_fund][i].votingCount;
			isVoting_[i] = isVoting(_fund, i, _sender);
		}
	}

    function getDistributionsCount(address _fund) external view returns(uint256 count_) {
        count_ = funds[_fund].length;
    }

    function isVoting(address _fund, uint256 _index, address _sender) public view returns (bool){
		return funds[_fund][_index].voting[_sender];
	}

    function vote(address _fund, uint256 _index, address _sender) external {
		require(IFund(_fund).isSupporter(_sender));
		require(funds[_fund].length > _index);
		require(funds[_fund][_index].state == State.PENDING);
		uint256 votableTime = funds[_fund][_index].distributableTime;
		require(TimeLib.currentTime().between(votableTime.sub(funds[_fund][_index].interval), votableTime));

		if (funds[_fund][_index].voting[_sender]) {
			revert();
		} else {
			funds[_fund][_index].voting[_sender] = true;
			funds[_fund][_index].votingCount = funds[_fund][_index].votingCount.add(1);
			if (IFund(_fund).getSupporterCount().mul(10 ** 18).div(2) <= funds[_fund][_index].votingCount.mul(10 ** 18)) {
                funds[_fund][_index].state = State.CANCEL_PAYMENT;
				addDistribution(
                    funds[_fund][_index].fund,
                    funds[_fund][_index].writer,
                    funds[_fund][_index].interval,
                    funds[_fund][_index].amount);
			}
		}
	}

    function releaseDistribution(address _fund) external {
        require(ICouncil(council).getApiFund() == msg.sender);

        ERC20 token = ERC20(ICouncil(council).getToken());
        for (uint256 i = 0; i < funds[_fund].length; i++) {
            if (distributable(funds[_fund][i])) {
                funds[_fund][i].distributedTime = TimeLib.currentTime();
                funds[_fund][i].state = State.PAID;
                token.safeTransfer(funds[_fund][i].writer, funds[_fund][i].amount);

                emit ReleaseDistribution(_fund, funds[_fund][i].amount);
            }
        }
    }

    function distributable(Distribution memory _distribution) private view returns (bool) {
		return _distribution.distributableTime <= TimeLib.currentTime() && _distribution.state == State.PENDING && _distribution.amount > 0;
	}

	event ReleaseDistribution(address _fund, uint256 _amount);
}
