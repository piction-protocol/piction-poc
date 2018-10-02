pragma solidity ^0.4.24;

import "contracts/interface/IContent.sol";
import "contracts/interface/IFundManager.sol";
import "contracts/interface/ICouncil.sol";

import "contracts/supporter/Fund.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";

contract FundManager is IFundManager, ExtendsOwnable, ValidValue {
	using TimeLib for *;

	mapping(address => address[]) funds;
	address council;

	constructor(address _council) public validAddress(_council){
		council = _council;
	}

	/**
	* @dev 작품의 투자를 생성함
	* @param _content 생성할 작품의 주소
	* @param _startTime 투자를 시작할 시간
	* @param _endTime 투자를 종료하는 시간
	* @param _maxcap 투자 총 모집금액
	* @param _softcap 투자 총 모집금액 하한
	* @param _poolSize 몇회에 걸쳐 후원 받을것인가
	* @param _releaseInterval 후원 받을 간격
	* @param _distributionRate 서포터가 분배 받을 비율
	* @param _detail 투자의 기타 상세 정보
	*/
	function addFund(
		address _content,
		uint256 _startTime,
		uint256 _endTime,
		uint256 _maxcap,
        uint256 _softcap,
		uint256 _poolSize,
		uint256 _releaseInterval,
		uint256 _distributionRate,
		string _detail)
	external {
		require(ICouncil(council).getApiFund() == msg.sender);
		require(getLastFundedTime(_content) < TimeLib.currentTime());

		Fund fund = new Fund(
			council,
			_content,
			_startTime,
			_endTime,
			_maxcap,
			_softcap,
			_poolSize,
			_releaseInterval,
			_distributionRate,
			_detail);

		funds[_content].push(fund);

		emit RegisterFund(_content, fund);
	}

	/**
	* @dev 작품의 투자 목록을 가져옴
	* @param _content 작품의 주소
	* @return funds_ 작품의 투자 주소목록
	*/
	function getFunds(address _content) external view returns (address[] funds_) {
		return funds[_content];
	}

	/**
	* @dev 작품에서 마지막 투자의 종료시간 조회
	* @param _content 작품 주소
	* @return endTime_ 종료시간
	*/
	function getLastFundedTime(address _content) private view returns (uint256 endTime_) {
		if (funds[_content].length > 0) {
			uint256 lastIndex = funds[_content].length - 1;
			return Fund(funds[_content][lastIndex]).endTime();
		} else {
			return 0;
		}
	}

	/**
	* @dev 작품의 판매금 정산을 위해 호출함
	* @param _fund 투자의 주소
	* @param _total 정산해야할 금액
	* @return supporter_ 정산해야하는 투자자 주소
	* @return amount_ 정산해야하는 금액
	*/
	function distribution(address _fund, uint256 _total) external returns (address[] supporter_, uint256[] amount_) {
		require(
			msg.sender == ICouncil(council).getPixelDistributor()
			|| msg.sender == ICouncil(council).getDepositPool());

		return Fund(_fund).distribution(_total);
	}

	event RegisterFund(address _content, address _fund);
}
