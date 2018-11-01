pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IReport.sol";
import "contracts/interface/IDepositPool.sol";

import "contracts/token/CustomToken.sol";
import "contracts/token/ContractReceiver.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";

contract Report is ExtendsOwnable, ValidValue, ContractReceiver, IReport {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    uint256 DECIMALS = 10 ** 18;

    //위원회
    ICouncil council;

    //유저 등록금
    // amount 등록금의 양
    // lockTime 잠김이 풀리는 시간
    // block 유저의 블락 유무
    struct Registration {
        address reporter;
        uint256 amount;
        uint256 lockTime;
        bool reporterBlock;
    }
    mapping (address => Registration) registrationFee;

    //신고자 등록금 잠금 시간
    uint256 interval = 30 * 60 * 1000; //for test 30 min

    //신고내용과 처리유무
    struct ReportData {
        uint256 reportDate;
        address content;
        address reporter;
        string detail;
        uint256 completeDate;
        uint256 completeType;
        uint256 completeAmount;
    }
    //신고 목록
    ReportData[] reports;

    //처리되지 않은 작품 별 신고 개수
    mapping (address => uint256) reportCount;

    /**
    * @dev 생성자
    * @param _councilAddress 위원회 주소
    */
    constructor(address _councilAddress) public validAddress(_councilAddress) {
        council = ICouncil(_councilAddress);
    }

    /**
    * @dev Token의 ApproveAndCall이 호출하는 Contract의 함수
    * @param _from 토큰을 보내는 주소
    * @param _value 토큰의 양
    * @param _token 토큰의 주소
    */
    function receiveApproval(address _from, uint256 _value, address _token, bytes _data) public {
        registration(_from, _value, _token);
    }

    /**
    * @dev receiveApproval의 구현, token을 전송 받고 신고자의 등록금을 기록함
    */
    function registration(address _from, uint256 _value, address _token) private {
        require(council.getReportRegistrationFee() == _value, "value error");
        require(registrationFee[_from].amount == 0, "already registration");
        require(!registrationFee[_from].reporterBlock, "repoter is Block");
        ERC20 token = ERC20(council.getToken());
        require(address(token) == _token, "token is abnormal");

        registrationFee[_from].amount = _value;
        registrationFee[_from].lockTime = TimeLib.currentTime().add(interval);
        registrationFee[_from].reporterBlock = false;

        CustomToken(address(token)).transferFromPxl(_from, address(this), _value, "신고 보증금 예치");

        emit RegistrationFee(TimeLib.currentTime(), _from, _value);
    }

    /**
    * @dev 신고자가 어떤 작품에 대해 신고를 함, 위원회의 보증금 변경과 관계없이 동작함(추후 논의)
    * @param _detail 신고정보
    */
    function sendReport(address _content, address reporter, string _detail)
        external
        validAddress(_content)
        validAddress(reporter)
        validString(_detail)
    {
        require(council.getApiReport() == msg.sender, "msg sender is not ApiReport");
        require(registrationFee[reporter].amount > 0, "Insufficient registrationFee");
        require(!registrationFee[reporter].reporterBlock, "repoter is block");
        require(registrationFee[reporter].lockTime > TimeLib.currentTime(), "over the lockTime");

        reports.push(ReportData(TimeLib.currentTime(), _content, reporter, _detail, 0, 0, 0));
        reportCount[_content] = reportCount[_content].add(1);

        emit SendReport(TimeLib.currentTime(), reports.length-1, _content, reporter, _detail);
    }

    /**
    * @dev 신고한 내용을 가져옴
    * @param _index 신고 목록의 인덱스
    */
    function getReport(uint256 _index)
        external
        view
        returns(uint256 reportDate_, address content_, address reporter_, string detail_, uint256 completeDate_, uint256 completeType_, uint256 completeAmount_)
    {
        return
        (
            reports[_index].reportDate,
            reports[_index].content,
            reports[_index].reporter,
            reports[_index].detail,
            reports[_index].completeDate,
            reports[_index].completeType,
            reports[_index].completeAmount
        );
    }

    /**
    * @dev 작품의 신고 건수 조회
    * @param _content 확인할 작품의 주소
    */
    function getReportCount(address _content) external view returns(uint256 count_) {
        for(uint256 i = 0; i < reports.length; i++) {
            if (reports[i].content == _content) {
                count_ = count_.add(1);
            }
        }
    }

    /**
    * @dev 작품의 신고 중 처리되지 않은 건수 조회
    * @param _content 확인할 작품의 주소
    */
    function getUncompletedReportCount(address _content) external view returns(uint256 count_) {
        return reportCount[_content];
    }

    /**
    * @dev 신고 처리 완료 후 호출하는 메소드, deduction나 DepositPool의 reportReward 처리 후 호출
    * @param _index 신고 목록의 인덱스
    * @param _type 신고처리 타입 / 1 작품 차단, 2 작품 경고, 3 신고 무효, 4 중복 신고, 5 잘못된 신고
    * @param _deductionAmount 변경된 관련 금액
    */
    function completeReport(uint256 _index, uint256 _type, uint256 _deductionAmount) external {
        require(msg.sender == address(council), "msg sender is not council");
        require(_index < reports.length, "out of index");
        require(reports[_index].completeDate == 0, "already complete");
        require(_type != 0, "type error");
        require(reportCount[reports[_index].content] > 0, "reportCount error");

        reports[_index].completeDate = TimeLib.currentTime();
        reports[_index].completeType = _type;
        reports[_index].completeAmount = _deductionAmount;

        reportCount[reports[_index].content] = reportCount[reports[_index].content].sub(1);

        emit CompleteReport(reports[_index].reportDate, reports[_index].completeDate, _index, reports[_index].content, reports[_index].reporter, reports[_index].detail, _type, _deductionAmount);
    }

    /**
    * @dev 문제가 있는 신고자의 RegFee 차감, 위원회가 호출함
    * @param _reporter 차감 시킬 대상
    */
    function deduction(address _reporter) external validAddress(_reporter) returns(uint256 deduction_) {
        require(msg.sender == address(council), "msg sender is not council");

        uint256 onePXL = 1 * DECIMALS;
        uint256 remain;
        if (registrationFee[_reporter].amount > 0) {
            if (registrationFee[_reporter].amount >= onePXL) {
                remain = registrationFee[_reporter].amount.sub(onePXL);
                registrationFee[_reporter].amount = remain;
                deduction_ = onePXL;
                if (remain == 0) {
                    registrationFee[_reporter].reporterBlock = true;
                }
            } else {
                deduction_ = registrationFee[_reporter].amount;
                registrationFee[_reporter].amount = 0;
                registrationFee[_reporter].reporterBlock = true;
            }

            ERC20 token = ERC20(council.getToken());
            //임시 Ecosystem Growth Fund가 없음으로 위원회로 전송함
            CustomToken(address(token)).transferPxl(address(council), deduction_, "신고 보증금 차감");
        }

        emit Deduction(_reporter, deduction_);
    }

    /**
    * @dev 신고자가 맞긴 보증금을 찾아감
    */
    function withdrawRegistration(address _reporter) external {
        require(council.getApiReport() == msg.sender, "msg sender is not ApiReport");
        require(registrationFee[_reporter].amount > 0, "empty amount");
        require(registrationFee[_reporter].lockTime < TimeLib.currentTime(), "not over locktime");

        ERC20 token = ERC20(council.getToken());
        uint256 tempAmount = registrationFee[_reporter].amount;

        registrationFee[_reporter].amount = 0;
        CustomToken(address(token)).transferPxl(_reporter, tempAmount, "신고 보증금 환불");

        emit WithdrawRegistration(_reporter, tempAmount);
    }

    /**
    * @dev 신고자가 맞긴 신고 보증금 잔액을 조회한다
    * @param _reporter 확인 할 대상
    */
    function getRegistrationAmount(address _reporter) external view returns(uint256 amount_) {
        return registrationFee[_reporter].amount;
    }

    /**
    * @dev 신고자의 신고 보증금 잠금 기간을 조회한다
    * @param _reporter 확인 할 대상
    */
    function getRegistrationLockTime(address _reporter) external view returns(uint256 lockTime_) {
        return registrationFee[_reporter].lockTime;
    }

    /**
    * @dev 신고자의 블락 유무를 조회한다
    * @param _reporter 확인 할 대상
    */
    function getReporterBlock(address _reporter) external view returns(bool isBlock_) {
        return registrationFee[_reporter].reporterBlock;
    }

    event RegistrationFee(uint256 _date, address _from, uint256 _value);
    event Deduction(address _reporter, uint256 _amount);
    event ReporterBlock(address _reporter);
    event SendReport(uint256 _date, uint256 indexed _index, address indexed _content, address indexed _from, string _detail);
    event WithdrawRegistration(address _to, uint256 _amount);
    event CompleteReport(uint256 _reportDate, uint256 _completeDate, uint256 indexed _index, address indexed _content, address indexed _from, string _detail, uint256 _type, uint256 _deductionAmount);
}
