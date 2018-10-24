pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IFund.sol";
import "contracts/interface/ISupporterPool.sol";
import "contracts/token/CustomToken.sol";

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

    /**
    * @dev 투자가 종료된 후 내역저장과 후원을 위해 addDistribution을 진행함
    * @param _fund 종료된 투자의 주소
    * @param _writer 후원받을 작가의 주소
    * @param _interval 후원받을 간격
    * @param _amount 후원받을 금액
    * @param _size 후원받을 횟수
    * @param _supportFirstTime 첫 후원을 받을 수 있는 시간
    */
    function addSupport(
        address _fund,
        address _writer,
        uint256 _interval,
        uint256 _amount,
        uint256 _size,
        uint256 _supportFirstTime)
        external
    {
        require(_fund == msg.sender, "msg sender is not fund");
        
        uint256 poolAmount = _amount.div(_size);
        for (uint256 i = 0; i < _size; i++) {
            addDistribution(_fund, _writer, _interval, _supportFirstTime, poolAmount);
        }

        uint256 remainder = _amount.sub(poolAmount.mul(_size));
        if (remainder > 0) {
            funds[_fund][funds[_fund].length - 1].amount = funds[_fund][funds[_fund].length - 1].amount.add(remainder);
        }
    }

    /**
    * @dev 후원 회차를 생성함
    * @param _fund 종료된 투자의 주소
    * @param _writer 후원받을 작가의 주소
    * @param _interval 후원받을 간격
    * @param _supportFirstTime 첫 후원을 받을 수 있는 시간
    * @param _amount 후원받을 금액
    */
    function addDistribution(
        address _fund,
        address _writer,
        uint256 _interval,
        uint256 _supportFirstTime,
        uint256 _amount)
        private
    {
        uint256 _distributableTime;
        if (funds[_fund].length == 0) {
            _distributableTime = _supportFirstTime;
        } else {
            _distributableTime = funds[_fund][funds[_fund].length - 1].distributableTime.add(_interval);
        }
        funds[_fund].push(Distribution(_fund, _writer, _interval, _amount, _distributableTime, 0, State.PENDING, 0));
    }

    /**
    * @dev 투자 풀의 후원 순차 상태 조회
    * @param _fund 조회 하고자 하는 투자 주소
    * @param _sender 조회 하고자 하는 투자자 주소
    * @return amount_ 투자금 목록
    * @return distributableTime_ 분배 가능한 시작시간
    * @return distributedTime_ 분배를 진행한 시간
    * @return isVoting_ 호출자의 투표 여부
    */
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
            isVoting_[i] = funds[_fund][i].voting[_sender];
        }
    }

    /**
    * @dev 후원회차의 개수
    * @param _fund 투자의 주소
    * @return count_ 후원회차의 개수
    */
    function getDistributionsCount(address _fund) external view returns(uint256 count_) {
        count_ = funds[_fund].length;
    }

    /**
    * @dev 후원 회차의 투표 여부확인
    * @param _fund 투자한 fund 주소
    * @param _index 회차 Index
    * @param _sender 확인하고자 하는 투자자 주소
    * @return voting_ 투표 여부
    */
    function isVoting(address _fund, uint256 _index, address _sender) external view returns (bool voting_){
        return funds[_fund][_index].voting[_sender];
    }

    /**
    * @dev 투자자가 후원 풀의 배포 건에 대해 투표를 함
    * @param _fund 투표할 투자 주소
    * @param _index 투표할 회차의 index
    * @param _sender 투표 하고자 하는 투자자 주소
    */
    function vote(address _fund, uint256 _index, address _sender) external {
        require(ICouncil(council).getApiFund() == msg.sender, "sender is not ApiFund");
        require(IFund(_fund).isSupporter(_sender), "sender is not Supporter");
        require(funds[_fund].length > _index, "fund length error");
        require(funds[_fund][_index].state == State.PENDING, "fund state error");
        uint256 votableTime = funds[_fund][_index].distributableTime;
        require(TimeLib.currentTime().between(votableTime.sub(funds[_fund][_index].interval), votableTime), "fund vote time error");
        require(!funds[_fund][_index].voting[_sender], "already vote");
        
        funds[_fund][_index].voting[_sender] = true;
        funds[_fund][_index].votingCount = funds[_fund][_index].votingCount.add(1);
        if (IFund(_fund).getSupporterCount().mul(10 ** 18).div(2) <= funds[_fund][_index].votingCount.mul(10 ** 18)) {
            funds[_fund][_index].state = State.CANCEL_PAYMENT;
            addDistribution(
                funds[_fund][_index].fund,
                funds[_fund][_index].writer,
                funds[_fund][_index].interval,
                0,
                funds[_fund][_index].amount);
        }
    
    }

    /**
    * @dev 조건에 맞는 후원 풀 회차의 토큰을 작가에게 전달한다
    * @param _fund 배포하고자 하는 투자 주소
    */
    function releaseDistribution(address _fund) external {
        require(ICouncil(council).getApiFund() == msg.sender, "msg sender is not ApiFund");

        ERC20 token = ERC20(ICouncil(council).getToken());
        for (uint256 i = 0; i < funds[_fund].length; i++) {
            if (distributable(funds[_fund][i])) {
                funds[_fund][i].distributedTime = TimeLib.currentTime();
                funds[_fund][i].state = State.PAID;
                CustomToken(address(token)).transferPxl(funds[_fund][i].writer, funds[_fund][i].amount, "투자 모금액 수령");

                emit ReleaseDistribution(_fund, funds[_fund][i].amount);
            }
        }
    }

    /**
    * @dev 후원 회차의 배포가 진행될 수 있는지 확인
    * @param _distribution 배포하고자 하는 후원회차
    * @return distributable_ 가능 여부
    */
    function distributable(Distribution memory _distribution) private view returns (bool distributable_) {
        return _distribution.distributableTime <= TimeLib.currentTime() && _distribution.state == State.PENDING && _distribution.amount > 0;
    }

    event ReleaseDistribution(address _fund, uint256 _amount);
}
