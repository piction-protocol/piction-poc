pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/interface/IContent.sol";
import "contracts/interface/ICouncil.sol";
import "contracts/interface/IDepositPool.sol";
import "contracts/interface/IReport.sol";

import "contracts/token/CustomToken.sol";
import "contracts/token/ContractReceiver.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/BytesLib.sol";
import "contracts/utils/TimeLib.sol";

/**
 * @title DepositPool
 * @dev 작품 초기 업로드 시 필요한 보증금의 적립과 판매금의 특정비율을 적립.
 *      신고자에 대한 보상으로 특정 금액을 전송.
 *      작품 완결 시 서포터 정산 후 작가에게 잔액 전송.
 */
contract DepositPool is ExtendsOwnable, ValidValue, ContractReceiver, IDepositPool {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using BytesLib for bytes;

    uint256 DECIMALS = 10 ** 18;

    ICouncil council;
    mapping (address => uint256) contentDeposit;
    mapping (address => uint256) possibleReleaseDate;

    /**
    * @dev 생성자
    * @param _councilAddress 위원회 주소
    */
    constructor(address _councilAddress) public validAddress(_councilAddress) {
        council = ICouncil(_councilAddress);
    }

    /**
    * @dev Token의 ApproveAndCall이 호출하는 Contract의 함수
    * @param _from 허가자
    * @param _value 전송량
    * @param _token 실행되는 토큰 주소
    * @param _data 전송된 데이터
    */
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes _data)
        public
        validAddress(_from)
        validAddress(_token)
    {
        addDeposit(_from, _value, _token, _data);
    }

    /**
    * @dev receiveApproval의 구현, token을 전송 받고 Content 별로 잔액을 기록함
    */
    function addDeposit(address _from, uint256 _value, address _token, bytes _data) private {
        require(council.getContentsManager() == _from, "msg sender is not contentManager");
        require(_data.length > 0, "data is empty");
        require(contentDeposit[content] == 0, "deposit not empty");
        ERC20 token = ERC20(council.getToken());
        require(address(token) == _token, "token abnormal");

        address content = _data.toAddress(0);
        contentDeposit[content] = contentDeposit[content].add(_value);
        CustomToken(address(token)).transferFromPxl(_from, address(this), _value, "작품 등록 예치금 입금");
        
        uint256 releaseDate = TimeLib.currentTime() + council.getDepositReleaseDelay();
        setReleaseDate(content, releaseDate);

        emit AddDeposit(content, _value, _token);
    }

    event AddDeposit(address content, uint256 _value, address _token);

    /**
    * @dev Content 별 쌓여있는 Deposit의 양을 반환함
    * @param _content 작품의 주소
    */
    function getDeposit(address _content) external view returns(uint256 depositAmount_) {
        return contentDeposit[_content];
    }

    /**
    * @dev 예치금을 회수할 수있는 날짜를 설정
    * @param _content 날짜를 설정할 작품 주소
    * @param _currentDate 설정할 날짜
    */
    function setReleaseDate(address _content, uint256 _currentDate) private validAddress(_content) {
        possibleReleaseDate[_content] = _currentDate;
    }

    /**
    * @dev 예치금을 회수할 수있는 날짜 조회
    * @param _content 작품 주소
    */
    function getReleaseDate(address _content) external view returns(uint256 releaseDate_) {
        return possibleReleaseDate[_content];
    }
    
    /**
    * @dev 위원회가 호출하는 보증금 차감 및 신고자 보상 처리
    * @param _content 신고한 작품 주소
    * @param _reporter 신고자 주소
    * @param _type 처리 타입, 1 : 전액 차감, 2 : 1PXL 차감
    */
    function reportReward(address _content, address _reporter, uint256 _type, string _descripstion)
        external
        validAddress(_content)
        validAddress(_reporter)
        returns(uint256 deduction_, bool contentBlock_)
    {
        require(address(council) == msg.sender, "msg sender is not council");
        require(_type > 0 && _type < 3, "out of type");

        if (contentDeposit[_content] > 0) {
            ERC20 token = ERC20(council.getToken());
            uint256 rewardOnePXL = 1 * DECIMALS;

            if (contentDeposit[_content] >= rewardOnePXL) {
                deduction_ = contentDeposit[_content].sub(rewardOnePXL);
                if (_type == 1) {
                    contentDeposit[_content] = 0;
                    contentBlock_ = true;
                } else if (_type == 2) {
                    contentDeposit[_content] = contentDeposit[_content].sub(rewardOnePXL);
                    if (deduction_ == 0) {
                        contentBlock_ = true;
                    }
                    deduction_ = 0;
                }
            } else {
                rewardOnePXL = contentDeposit[_content];
                contentDeposit[_content] = 0;
                contentBlock_ = true;
            }

            require(token.balanceOf(address(this)) >= deduction_ + rewardOnePXL, "token balance abnormal");
            if (deduction_ > 0) {
                CustomToken(address(token)).transferPxl(address(council), deduction_, "신고 보증금 차감");
            }
            
            if (rewardOnePXL > 0) {
                CustomToken(address(token)).transferPxl(_reporter, rewardOnePXL, "신고 활동 보상금");
                deduction_ = deduction_ + rewardOnePXL;
            }
        }

        setReleaseDate(_content, TimeLib.currentTime() + council.getDepositReleaseDelay());

        emit DepositChange(TimeLib.currentTime(), _content, _type, deduction_, _descripstion);
    }

    /**
    * @dev 작품 완결 시 호출하는 정산 구현
    * @param _content 정산을 원하는 작품 주소
    */
    function release(address _content) external validAddress(_content) {
        require(contentDeposit[_content] > 0, "contentDeposit is zero");
        address writer = IContent(_content).getWriter();
        require(writer == msg.sender, "msg sender is not writer");
        require(possibleReleaseDate[_content] <= TimeLib.currentTime(), "releaseData setError");

        ERC20 token = ERC20(council.getToken());
        require(token.balanceOf(address(this)) >= contentDeposit[_content], "token balance abnormal");
        
        uint256 amount = contentDeposit[_content];
        contentDeposit[_content] = 0;
        CustomToken(address(token)).transferPxl(writer, amount, "작품 등록 예치금 회수");
        
        emit DepositChange(TimeLib.currentTime(), _content, 6, amount, "작품 등록 예치금 회수");
    }

    event DepositChange(uint256 _date, address indexed _content, uint256 _type, uint256 _amount, string _description);
}
