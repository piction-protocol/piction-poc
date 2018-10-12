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

    /**
    * @dev 투자 가능한 금액과 환불금을 산출함
    * @param _fromValue 투자를 원하는 금액
    * @return possibleValue_ 투자 가능한 금액
    * @return refundValue_ maxcap 도달로 환불해야하는 금액
    */
    function getRefundAmount(uint256 _fromValue) private view returns (uint256 possibleValue_, uint256 refundValue_) {
        uint256 d1 = maxcap.sub(fundRise);
        possibleValue_ = d1.min(_fromValue);
        refundValue_ = _fromValue.sub(possibleValue_);
    }

    /**
    * @dev 투자의 종료를 진행, 후원 풀로 토큰을 전달하며 softcap 미달 시 환불을 진행함
    */
    function endFund() external {
        require(ICouncil(council).getApiFund() == msg.sender);
        require(ISupporterPool(ICouncil(council).getSupporterPool()).getDistributionsCount(address(this)) == 0);
        require(fundRise == maxcap || TimeLib.currentTime() > endTime);

        uint256 totalInvestment;
        for (uint256 i = 0; i < supporters.length; i++) {
            totalInvestment = totalInvestment.add(supporters[i].investment);
        }
        ERC20 token = ERC20(ICouncil(council).getToken());
        require(totalInvestment == token.balanceOf(address(this)));

        if (fundRise >= softcap) {
            setDistributionRate();
            ISupporterPool(ICouncil(council).getSupporterPool()).addSupport(address(this), writer, releaseInterval, fundRise, poolSize);

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
        require(ICouncil(council).getFundManager() == msg.sender);

        supporters_ = new address[](supporters.length);
        amounts_ = new uint256[](supporters.length);

        for (uint256 i = 0; i < supporters.length; i++) {
            supporters_[i] = supporters[i].user;
            uint256 remain = supporters[i].investment.sub(supporters[i].collection);
            if (remain == 0) {
                amounts_[i] = _total.mul(distributionRate).div(10 ** decimals);
                amounts_[i] = amounts_[i].mul(supporters[i].distributionRate).div(10 ** decimals);
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

    /**
    * @dev 투자 참여인원 수 조회
    */
    function getSupporterCount() public view returns (uint256) {
        return supporters.length;
    }

    /**
    * dev 투자 정보 조회
    * @return _startTime 투자를 시작할 시간
    * @return _endTime 투자를 종료하는 시간
    * @return _maxcap 투자 총 모집금액
    * @return _softcap 투자 총 모집금액 하한
    * @return _poolSize 몇회에 걸쳐 후원 받을것인가
    * @return _releaseInterval 후원 받을 간격
    * @return _distributionRate 서포터가 분배 받을 비율
    * @return _detail 투자의 기타 상세 정보
    */
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

    event Support(address _from, uint256 _amount, uint256 _refundAmount);
    event Refund(address _to, uint256 _amount);
}
