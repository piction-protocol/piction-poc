pragma solidity ^0.4.24;

import "contracts/interface/IContent.sol";
import "contracts/interface/ICouncil.sol";
import "contracts/interface/IFund.sol";
import "contracts/interface/ISupporterPool.sol";
import "contracts/interface/IFundManager.sol";

import "contracts/utils/ValidValue.sol";

contract ApiFund is ValidValue {

    //위원회
    ICouncil council;

    constructor(address _councilAddress) public validAddress(_councilAddress) {
        council = ICouncil(_councilAddress);
    }

    ////-------- FundManager 관련 --------
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
        external
    {
        require(IContent(_content).getWriter() == msg.sender);

        IFundManager(council.getFundManager()).addFund(_content, _startTime, _endTime, _maxcap, _softcap, _poolSize, _releaseInterval, _distributionRate, _detail);

        emit AddFund(_content, _startTime, _endTime, _maxcap, _softcap, _poolSize, _releaseInterval, _distributionRate, _detail);
    }

    event AddFund(address _content, uint256 _startTime, uint256 _endTime, uint256 _maxcap, uint256 _softcap, uint256 _poolSize, uint256 _releaseInterval, uint256 _distributionRate, string _detail);

    /**
    * @dev 작품의 투자 목록을 가져옴
    * @param _content 작품의 주소
    * @return funds_ 작품의 투자 주소목록
    */
    function getFunds(address _content) external view returns (address[] funds_) {
        return IFundManager(council.getFundManager()).getFunds(_content);
    }

    ////-------- Fund 관련 --------

    /**
    * @dev 투자를 종료하고 서포터 풀로 토큰을 이동시킴
    * @param _fund 종료시킬 투자의 주소
    */
    function endFund(address _fund) external {
        IFund(_fund).endFund();

        emit EndFund(_fund);
    }

    event EndFund(address _fund);

    /**
    * @dev 투자자 정보 조회
    * @param _fund 조회하고자 하는 투자 주소
    * @return user_ 투자자의 주소 목록
    * @return investment_ 투자자의 투자금액 목록
    * @return distributionRate_ 투자자의 투자금액 회수액 목록
    * @return refund_ 환불 여부 목록
    */
    function getSupporters(address _fund)
		external
		view
		returns (
			address[] memory user_,
			uint256[] memory investment_,
			uint256[] memory collection_,
			uint256[] memory distributionRate_,
            bool[] memory refund_)
	{
        return IFund(_fund).getSupporters();
    }

    /**
    * dev 투자 정보 조회
    * @param _fund 조회하고자 하는 투자 주소
    * @return _startTime 투자를 시작할 시간
    * @return _endTime 투자를 종료하는 시간
    * @return _maxcap 투자 총 모집금액
    * @return _softcap 투자 총 모집금액 하한
    * @return _poolSize 몇회에 걸쳐 후원 받을것인가
    * @return _releaseInterval 후원 받을 간격
    * @return _distributionRate 서포터가 분배 받을 비율
    * @return _detail 투자의 기타 상세 정보
    */
    function fundInfo(address _fund)
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
        return IFund(_fund).info();
    }

    ////-------- SupporterPool 관련 --------

    /**
    * @dev 조건에 맞는 후원 풀 배포 건의 토큰을 작가에게 전달한다
    * @param _fund 배포하고자 하는 투자 주소
    */
    function releaseDistribution(address _fund) external {
        ISupporterPool(council.getSupporterPool()).releaseDistribution(_fund);

        emit ReleaseDistribution(_fund);
    }

    event ReleaseDistribution(address _fund);

    /**
    * @dev 투자 풀의 후원 순차 상태 조회
    * @param _fund 조회 하고자 하는 투자 주소
    * @return amount_ 투자금 목록
    * @return distributableTime_ 분배 가능한 시작시간
    * @return distributedTime_ 분배를 진행한 시간
    * @return isVoting_ 호출자의 투표 여부
    */
    function getDistributions(address _fund)
        external
        view
        returns (
            uint256[] memory amount_,
            uint256[] memory distributableTime_,
            uint256[] memory distributedTime_,
            uint256[] memory state_,
            uint256[] memory votingCount_,
            bool[] memory isVoting_)
        {
            return ISupporterPool(council.getSupporterPool()).getDistributions(_fund, msg.sender);
        }

    /**
    * @dev 투자자가 후원 풀의 배포 건에 대해 투표를 함
    * @param _fund 투표할 투자 주소
    * @param _index 투표할 회차의 index
    */
    function vote(address _fund, uint256 _index) external {
        ISupporterPool(council.getSupporterPool()).vote(_fund, _index, msg.sender);

        emit Vote(_fund, _index, msg.sender);
    }

    event Vote(address _fund, uint256 _index, address _sender);

    /**
    * @dev 후원 회차의 투표 여부확인
    * @param _fund 투자한 fund 주소
    * @param _index 회차 Index
    * @return voting_ 투표 여부
    */
    function isVoting(address _fund, uint256 _index) external view returns (bool voting_) {
        return ISupporterPool(council.getSupporterPool()).isVoting(_fund, _index, msg.sender);
    }
}
