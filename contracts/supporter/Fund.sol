pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/interface/IContent.sol";
import "contracts/interface/ICouncil.sol";
import "contracts/interface/IFund.sol";
import "contracts/interface/ISupporterPool.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/supporter/SupporterPool.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";

contract Fund is ContractReceiver, IFund, ExtendsOwnable, ValidValue {
	using Math for uint256;
	using SafeMath for uint256;
	using SafeERC20 for ERC20;
	using TimeLib for *;

	struct Supporter {
		address user;
		uint256 investment;
		uint256 collection;
		uint256 distributionRate;
		bool refund;
	}

	uint256 decimals = 18;

	uint256 startTime;
	uint256 public endTime;
	string detail;

	address council;
	address content;
	address writer;

	uint256 fundRise;
	uint256 maxcap;
	uint256 softcap;

	Supporter[] supporters;

	uint256 poolSize;
	uint256 releaseInterval;
	uint256 distributionRate;

	constructor(
		address _council,
		address _content,
		uint256 _startTime,
		uint256 _endTime,
		uint256 _maxcap,
        uint256 _softcap,
		uint256 _poolSize,
		uint256 _releaseInterval,
		uint256 _distributionRate,
		string _detail)
	public validAddress(_content) validAddress(_council) {
		require(_startTime > TimeLib.currentTime());
		require(_endTime > _startTime);
		require(_maxcap > _softcap);
		require(_poolSize > 0);
		require(_releaseInterval > 0);
		require(distributionRate <= 10 ** decimals);

		council = _council;
		content = _content;
		writer = IContent(_content).getWriter();
		startTime = _startTime;
		endTime = _endTime;
		maxcap = _maxcap;
		softcap = _softcap;
		detail = _detail;
		poolSize = _poolSize;
		releaseInterval = _releaseInterval;
		distributionRate = _distributionRate;
	}

	function receiveApproval(address _from, uint256 _value, address _token, bytes _data) public validAddress(_from) validAddress(_token) {
		support(_from, _value, _token);
	}

	/**
	* @dev Fund에 Token을 투자함, 투자금액이 maxcap을 넘어서면 차액을 환불홤
	* @param _from 투자자
	* @param _value 투자자의 투자금액
	* @param _token 사용된 Token Contract 주소
	*/
	function support(address _from, uint256 _value, address _token) private {
		require(TimeLib.currentTime().between(startTime, endTime));
		require(fundRise < maxcap);

		ERC20 token = ERC20(ICouncil(council).getToken());
		require(address(token) == _token);

		(uint256 possibleValue, uint256 refundValue) = getRefundAmount(_value);


		(uint256 index, bool success) = findSupporterIndex(_from);
		if (success) {
			supporters[index].investment = supporters[index].investment.add(possibleValue);
		} else {
			supporters.push(Supporter(_from, possibleValue, 0, 0, false));
		}

		fundRise = fundRise.add(possibleValue);
		token.safeTransferFrom(_from, address(this), _value);

		if (refundValue > 0) {
			token.safeTransfer(_from, refundValue);
		}

		emit Support(_from, possibleValue, refundValue);
	}

	function getRefundAmount(uint256 _fromValue) private view returns (uint256 possibleValue_, uint256 refundValue_) {
		uint256 d1 = maxcap.sub(fundRise);
		possibleValue_ = d1.min(_fromValue);
		refundValue_ = _fromValue.sub(possibleValue_);
	}

	function endFund() external {
		require(ICouncil(council).getApiFund() == msg.sender);
		require(ISupporterPool(ICouncil(council).getSupporterPool()).getDistributionsCount(address(this)) == 0);
		require(TimeLib.currentTime() > endTime);

		uint256 totalInvestment;
		for (uint256 i = 0; i < supporters.length; i++) {
			totalInvestment = totalInvestment.add(supporters[i].investment);
		}
		require(totalInvestment == token.balanceOf(address(this)));

		if (fundRise >= softcap) {
			setDistributionRate();
			ISupporterPool(ICouncil(council).getSupporterPool()).addSupport(address(this), writer, releaseInterval, fundRise, poolSize);

			ERC20 token = ERC20(ICouncil(council).getToken());
			token.safeTransfer(ICouncil(council).getSupporterPool(), fundRise);
		} else {
			//추후 환불 시 Block Gas limit 고려 필요
			for (uint256 j = 0; j < supporters.length; j++) {
				if (!supporters[j].refund) {
					supporters[j].refund = true;
					token.safeTransfer(supporters[j].user, supporters[j].investment);

					emit Refund(supporters[j].user, supporters[j].investment);
				}
			}
		}
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
		require(ICouncil(council).getFundManager() == msg.sender);

		address[] memory _supporters = new address[](supporters.length);
		uint256[] memory _amounts = new uint256[](supporters.length);

		for (uint256 i = 0; i < supporters.length; i++) {
			_supporters[i] = supporters[i].user;
			uint256 remain = supporters[i].investment.sub(supporters[i].collection);
			if (remain == 0) {
				_amounts[i] = _total.mul(distributionRate).div(10 ** decimals);
				_amounts[i] = _amounts[i].mul(supporters[i].distributionRate).div(10 ** decimals);
			} else {
				_amounts[i] = _total.mul(supporters[i].distributionRate).div(10 ** decimals).min(remain);
				supporters[i].collection = supporters[i].collection.add(_amounts[i]);
			}
		}
		return (_supporters, _amounts);
	}

	function getSupporters()
		external
		view
		returns (
			address[] memory user_,
			uint256[] memory investment_,
			uint256[] memory collection_,
			uint256[] memory distributionRate_,
			bool[] memory refund_)
	{
		user_ = new address[](supporters.length);
		investment_ = new uint256[](supporters.length);
		collection_ = new uint256[](supporters.length);
		distributionRate_ = new uint256[](supporters.length);
		refund_ = new bool[](supporters.length);

		for (uint256 i = 0; i < supporters.length; i++) {
			user_[i] = supporters[i].user;
			investment_[i] = supporters[i].investment;
			collection_[i] = supporters[i].collection;
			distributionRate_[i] = supporters[i].distributionRate;
			refund_[i] = supporters[i].refund;
		}
	}

	function getSupporterCount() public view returns (uint256) {
		return supporters.length;
	}

	function info()
		external
		view
		returns (
			uint256 startTime_,
			uint256 endTime_,
			uint256 maxcap_,
			uint256 softcap_,
			uint256 fundRise_,
			uint256 poolSize_,
			uint256 releaseInterval_,
			uint256 distributionRate_,
			string detail_)
	{
		startTime_ = startTime;
		endTime_ = endTime;
		maxcap_ = maxcap;
		softcap_ = softcap;
		fundRise_ = fundRise;
		poolSize_ = poolSize;
		releaseInterval_ = releaseInterval;
		distributionRate_ = distributionRate;
		detail_ = detail;
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

	event Support(address _from, uint256 _amount, uint256 _refundAmount);
	event Refund(address _to, uint256 _amount);
}
