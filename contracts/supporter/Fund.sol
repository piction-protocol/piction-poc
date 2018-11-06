pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/interface/IContent.sol";
import "contracts/interface/ICouncil.sol";
import "contracts/interface/IFund.sol";
import "contracts/interface/ISupporterPool.sol";
import "contracts/interface/IAccountManager.sol";

import "contracts/token/CustomToken.sol";
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
		uint256 reward;
		bool refund;
	}

	uint256 decimals = 18;

	uint256 startTime;
	uint256 endTime;
	string detail;

	address council;
	address content;
	address writer;

	uint256 fundRise;
	uint256 maxcap;
	uint256 softcap;
	uint256 minimum;
	uint256 maximum;

	Supporter[] supporters;

	uint256 poolSize;
	uint256 releaseInterval;
	uint256 supportFirstTime;
	uint256 distributionRate;

	bool isEndFund;

	constructor(
		address _council,
		address _content,
		uint256 _startTime,
		uint256 _endTime,
		uint256 _maxcap,
		uint256 _softcap,
		uint256 _minimum,
		uint256 _maximum,
		uint256 _poolSize,
		uint256 _releaseInterval,
		uint256 _supportFirstTime,
		uint256 _distributionRate,
		string _detail)
	public validAddress(_content) validAddress(_council) {
		require(_maxcap >= _softcap, "maxcap < softcap");
		require(_minimum > 0, "minimum is zero");
		require(_maximum > 0, "maximum is zero");
		require(_maxcap >= _maximum, "maxcap < maximum");
		require(_poolSize > 0, "poolsize is zero");
		require(_releaseInterval > 0, "releaseInterval is zero");
		require(_supportFirstTime > _endTime, "_supportFirstTime <= _endTime");
		require(distributionRate <= 10 ** decimals, "distributionRate > 10%");

		council = _council;
		content = _content;
		writer = IContent(_content).getWriter();

		if (_startTime <= TimeLib.currentTime()) {
			startTime = TimeLib.currentTime();
		} else {
			startTime = _startTime;
		}
		require(_endTime > _startTime, "startTime > endTime");

		endTime = _endTime;
		maxcap = _maxcap;
		softcap = _softcap;
		minimum = _minimum;
		maximum = _maximum;
		detail = _detail;
		poolSize = _poolSize;
		releaseInterval = _releaseInterval;
		supportFirstTime = _supportFirstTime;
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
		require(TimeLib.currentTime().between(startTime, endTime), "End Punding, Time");
		require(fundRise < maxcap, "End Punding, Maxcap");
		ERC20 token = ERC20(ICouncil(council).getToken());
		require(address(token) == _token, "token is abnormal");

		(uint256 index, bool success) = findSupporterIndex(_from);
		(uint256 possibleValue, uint256 refundValue) = getRefundAmount(success ? supporters[index].investment : 0, _value);

		CustomToken(address(token)).transferFromPxl(_from, address(this), _value, "서포터 참여, 투자금 모금");

		if (possibleValue > 0) {
			if (success) {
				supporters[index].investment = supporters[index].investment.add(possibleValue);
			} else {
				require(_value >= minimum, "value < minimum");
				supporters.push(Supporter(_from, possibleValue, 0, 0, 0, false));
			}

			fundRise = fundRise.add(possibleValue);
		}

		if (refundValue > 0) {
			CustomToken(address(token)).transferPxl(_from, refundValue, "서포터 참여, 투자금 환불");
		}

		// maxcap 도달시 강제 종료
		if (fundRise == maxcap) {
			endFund();
		}

		// update support history
		IAccountManager(ICouncil(council).getAccountManager()).setSupportHistory(_from, content, address(this), possibleValue, false);
		emit Support(_from, fundRise, maxcap, softcap, possibleValue, refundValue);
	}

	event Support(address _from, uint256 _fundRise, uint256 _maxcap, uint256 _softcap, uint256 _amount, uint256 _refundAmount);

	/**
	* @dev 투자 가능한 금액과 환불금을 산출함
	* @param _userValue 유저의 기존 투자금액
	* @param _fromValue 투자를 원하는 금액
	* @return possibleValue_ 투자 가능한 금액
	* @return refundValue_ maxcap 도달로 환불해야하는 금액
	*/
	function getRefundAmount(uint256 _userValue, uint256 _fromValue) private view returns (uint256 possibleValue_, uint256 refundValue_) {
		uint256 d1 = maxcap.sub(fundRise);
		uint256 d2 = maximum.sub(_userValue);
		possibleValue_ = (d1.min(d2)).min(_fromValue);
		refundValue_ = _fromValue.sub(possibleValue_);
	}

	/**
	* @dev 투자의 종료를 진행, 후원 풀로 토큰을 전달하며 softcap 미달 시 환불을 진행함
	*/
	function endFund() public {
		require(ISupporterPool(ICouncil(council).getSupporterPool()).getDistributionsCount(address(this)) == 0, "Fund SupporterPool is already");
		require(fundRise == maxcap || TimeLib.currentTime() > endTime, "fundRise not maxcap or endTime not over");

		uint256 totalInvestment;
		for (uint256 i = 0; i < supporters.length; i++) {
			totalInvestment = totalInvestment.add(supporters[i].investment);
		}
		ERC20 token = ERC20(ICouncil(council).getToken());
		require(totalInvestment == token.balanceOf(address(this)), "fund balance abnormal");

		CustomToken customToken = CustomToken(address(token));
		if (fundRise >= softcap) {
			setDistributionRate();
			ISupporterPool(ICouncil(council).getSupporterPool()).addSupport(address(this), writer, releaseInterval, fundRise, poolSize, supportFirstTime);

			customToken.transferPxl(ICouncil(council).getSupporterPool(), fundRise, "투자 종료, 후원풀로 전송");
			emit EndFund(true);
		} else {
			//추후 환불 시 Block Gas limit 고려 필요
			for (uint256 j = 0; j < supporters.length; j++) {
				if (!supporters[j].refund) {
					supporters[j].refund = true;
					customToken.transferPxl(supporters[j].user, supporters[j].investment, "투자 종료, 최소 모집 금액 미달성으로 환불");

					// update support history
					IAccountManager(ICouncil(council).getAccountManager()).setSupportHistory(supporters[j].user, content, address(this), supporters[j].investment, true);
					emit Refund(supporters[j].user, supporters[j].investment);
				}
			}
			emit EndFund(false);
		}
		isEndFund = true;
	}

	/*
	* @dev 투자자 별로 투자금 대비 정산 받을 비율을 설정함
	*/
	function setDistributionRate() private {
		uint256 totalInvestment;
		for (uint256 i = 0; i < supporters.length; i++) {
			totalInvestment = totalInvestment.add(supporters[i].investment);
		}
		for (i = 0; i < supporters.length; i++) {
			supporters[i].distributionRate = (10 ** decimals).mul(supporters[i].investment).div(totalInvestment);
		}
	}

	/*
	* @dev 작품 판매금의 투자자별 정산 금액을 계산하며 반환하고, 회수 내역을 저장함
	* @param _total 투자자가 받을 수 있는 금액 (우선순위가 높은 구성요소의 금액은 먼저 차감한 뒤 전달됨)
	* @return supporters_ 투자자의 주소
	* @return amounts_ 투자자가 정산받을 금액
	*/
	function distribution(uint256 _total) external returns (address[] memory supporters_, uint256[] memory amounts_) {
		require(ICouncil(council).getFundManager() == msg.sender, "msg sender is not FundManager");

		if (ISupporterPool(ICouncil(council).getSupporterPool()).getDistributionsCount(address(this)) == 0) {
			return;
		}

		supporters_ = new address[](supporters.length);
		amounts_ = new uint256[](supporters.length);

		for (uint256 i = 0; i < supporters.length; i++) {
			supporters_[i] = supporters[i].user;
			uint256 remain = supporters[i].investment.sub(supporters[i].collection);
			if (remain == 0) {
				amounts_[i] = _total.mul(distributionRate).div(10 ** decimals);
				amounts_[i] = amounts_[i].mul(supporters[i].distributionRate).div(10 ** decimals);
				supporters[i].reward = supporters[i].reward.add(amounts_[i]);
			} else {
				amounts_[i] = _total.mul(supporters[i].distributionRate).div(10 ** decimals).min(remain);
				supporters[i].collection = supporters[i].collection.add(amounts_[i]);
			}
		}
		return (supporters_, amounts_);
	}

	/**
	* @dev 투자자 정보 조회
	* @return user_ 투자자의 주소 목록
	* @return investment_ 투자자의 투자금액 목록
	* @return distributionRate_ 투자자의 투자금액 회수액 목록
	* @return refund_ 환불 여부 목록
	*/
	function getSupporters()
	external
	view
	returns (
		address[] memory user_,
		uint256[] memory investment_,
		uint256[] memory collection_,
		uint256[] memory reward_,
		uint256[] memory distributionRate_,
		bool[] memory refund_)
	{
		user_ = new address[](supporters.length);
		investment_ = new uint256[](supporters.length);
		collection_ = new uint256[](supporters.length);
		reward_ = new uint256[](supporters.length);
		distributionRate_ = new uint256[](supporters.length);
		refund_ = new bool[](supporters.length);

		for (uint256 i = 0; i < supporters.length; i++) {
			user_[i] = supporters[i].user;
			investment_[i] = supporters[i].investment;
			collection_[i] = supporters[i].collection;
			reward_[i] = supporters[i].reward;
			distributionRate_[i] = supporters[i].distributionRate;
			refund_[i] = supporters[i].refund;
		}
	}

	/**
	* @dev 투자 참여인원 수 조회
	*/
	function getSupporterCount() public view returns (uint256) {
		return supporters.length;
	}

	/**
	* dev 투자 정보 조회
	* @return startTime_ 투자를 시작할 시간
	* @return endTime_ 투자를 종료하는 시간
	* @return limit_ 투자 총 모집금액
	* @return poolSize_ 몇회에 걸쳐 후원 받을것인가
	* @return releaseInterval_ 후원 받을 간격
	* @return supportFirstTime_ 첫 후원을 받을 수 있는 시간
	* @return distributionRate_ 서포터가 분배 받을 비율
	* @return detail_ 투자의 기타 상세 정보
	*/
	function getFundInfo()
	external
	view
	returns (
		address content_,
		uint256 startTime_,
		uint256 endTime_,
		uint256[] memory limit_,
		uint256 fundRise_,
		uint256 poolSize_,
		uint256 releaseInterval_,
		uint256 supportFirstTime_,
		uint256 distributionRate_,
		bool needEndProcessing_,
		string detail_)
	{
		content_ = content;
		startTime_ = startTime;
		endTime_ = endTime;
		limit_ = new uint256[](4);
		limit_[0] = maxcap;
		limit_[1] = softcap;
		limit_[2] = minimum;
		limit_[3] = maximum;
		fundRise_ = fundRise;
		poolSize_ = poolSize;
		releaseInterval_ = releaseInterval;
		supportFirstTime_ = supportFirstTime;
		distributionRate_ = distributionRate;
		needEndProcessing_ = !isEndFund && (maxcap == fundRise || endTime < TimeLib.currentTime());
		detail_ = detail;
	}

	/**
	* @dev 투자자의 목록에서 투자자를 찾아 index와 투자여부를 반환함
	* @param _supporter 조회하는 투자자 주소
	* @return index_ 투자자의 Index
	* @return find_ 기존 투자여부
	*/
	function findSupporterIndex(address _supporter) private view returns (uint index_, bool find_){
		for (uint256 i = 0; i < supporters.length; i++) {
			if (supporters[i].user == _supporter) {
				return (i, true);
			}
		}
	}

	/**
	* @dev 투자 참여 여부 조회
	* @param _supporter 조회하고자 하는 주소
	* @return find_ 참여 여부
	*/
	function isSupporter(address _supporter) public view returns (bool find_){
		for (uint256 i = 0; i < supporters.length; i++) {
			if (supporters[i].user == _supporter) {
				return true;
			}
		}
	}

	event EndFund(bool success);
	event Refund(address _to, uint256 _amount);
}
