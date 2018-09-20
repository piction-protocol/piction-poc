pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IReport.sol";
import "contracts/interface/IDepositPool.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";

contract Report is ExtendsOwnable, ValidValue, ContractReceiver, IReport {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    //위원회
    ICouncil council;

    //유저 등록금
    // amount 등록금의 양
    // lockTime 잠김이 풀리는 시간
    // blockTime 다시 활동이 가능한 시간
    struct Registration {
        uint256 amount;
        uint256 lockTime;
        uint256 blockTime;
    }
    mapping (address => Registration) registrationFee;

    //신고자 등록금 잠금 시간
    uint256 interval = 10 * 60 * 1000; //for test 10 min

    //신고내용과 처리유무
    struct ReportData {
        address content;
        address reporter;
        string detail;
        bool complete;
        bool completeValid;
        uint256 completeAmount;
    }
    //신고 목록
    ReportData[] reports;

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
        require(council.getReportRegistrationFee() == _value);
        require(registrationFee[_from].amount == 0);
        require(registrationFee[_from].lockTime < TimeLib.currentTime());
        ERC20 token = ERC20(council.getToken());
        require(address(token) == _token);

        registrationFee[_from].amount = _value;
        registrationFee[_from].lockTime = TimeLib.currentTime().add(interval);
        token.safeTransferFrom(_from, address(this), _value);

        emit RegistrationFee(_from, _value, _token);
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
        require(council.getApiReport() == msg.sender);
        require(registrationFee[reporter].amount > 0);
        require(registrationFee[reporter].blockTime < TimeLib.currentTime());

        reports.push(ReportData(_content, reporter, _detail, false, false, 0));

        emit SendReport(reports.length-1, _content, reporter, _detail);
    }

    /**
    * @dev 신고한 내용을 가져옴
    * @param _index 신고 목록의 인덱스
    */
    function getReport(uint256 _index)
        external
        view
        returns(address content_, address reporter_, string detail_, bool complete_, bool completeValid_, uint256 completeAmount_)
    {
        return
        (
            reports[_index].content,
            reports[_index].reporter,
            reports[_index].detail,
            reports[_index].complete,
            reports[_index].completeValid,
            reports[_index].completeAmount
        );
    }

    /**
    * @dev 작품의 신고 건수 조회
    * @param _content 확인할 작품의 주소
    */
    function getReportCount(address _content) external view returns(uint256 count) {
        for(uint256 i = 0; i < reports.length; i++) {
            if (reports[i].content == _content) {
                count = count.add(1);
            }
        }
    }

    /**
    * @dev 작품의 신고 중 처리되지 않은 건수 조회, 작품 릴리즈 시 조회에 사용
    * @param _content 확인할 작품의 주소
    */
    function getUncompletedReport(address _content) external view returns(uint256 count) {
        for(uint256 i = 0; i < reports.length; i++) {
            if (reports[i].content == _content
                && reports[i].complete == false) {
                count = count.add(1);
            }
        }
    }

    /**
    * @dev 신고자의 신고 중 처리되지 않은 건수 조회, 신고자 신고금 반환 시 조회에 사용
    * @param _reporter 확인할 신고자의 주소
    */
    function getUncompletedReporter(address _reporter) private view returns(uint256 count) {
        for(uint256 i = 0; i < reports.length; i++) {
            if (reports[i].reporter == _reporter
                && reports[i].complete == false) {
                count = count.add(1);
            }
        }
    }

    /**
    * @dev 신고 처리 완료 후 호출하는 메소드, deduction나 DepositPool의 reportReward 처리 후 호출
    * @param _index 신고 목록의 인덱스
    * @param _reword 신고 리워드를 받았는가?
    * @param _rewordAmount 리워드 금액
    */
    function completeReport(uint256 _index, bool _reword, uint256 _rewordAmount) external {
        require(msg.sender == address(council));
        require(_index < reports.length);
        require(!reports[_index].complete);

        reports[_index].complete = true;
        reports[_index].completeValid = _reword;
        reports[_index].completeAmount = _rewordAmount;

        emit CompleteReport(_index, reports[_index].detail, _reword, _rewordAmount);
    }

    /**
    * @dev 문제가 있는 신고자의 RegFee 차감, 위원회가 호출함
    * @param _reporter 차감 시킬 대상
    */
    function deduction(address _reporter) external validAddress(_reporter) returns(uint256 result_) {
        require(msg.sender == address(council));

        uint256 amount = registrationFee[_reporter].amount;
        if (amount > 0) {
            registrationFee[_reporter].amount = 0;

            ERC20 token = ERC20(council.getToken());
            //임시 Ecosystem Growth Fund가 없음으로 위원회로 전송함
            token.safeTransfer(address(council), amount);
            result_ = amount;
        }

        emit Deduction(_reporter, result_);
    }

    /**
    * @dev 문제가 있는 신고자 추가 신고를 막음
    * @param _reporter 막을 대상
    */
    function reporterBlock(address _reporter) external {
        require(msg.sender == address(council));

        registrationFee[_reporter].blockTime = registrationFee[_reporter].lockTime;

        emit ReporterBlock(_reporter, registrationFee[_reporter].blockTime);
    }

    /**
    * @dev 신고자가 맞긴 보증금을 찾아감
    */
    function withdrawRegistration(address _reporter) external {
        require(council.getApiReport() == msg.sender);
        require(registrationFee[_reporter].amount > 0);
        require(registrationFee[_reporter].lockTime < TimeLib.currentTime());
        require(getUncompletedReporter(_reporter) == 0);

        ERC20 token = ERC20(council.getToken());
        uint256 tempAmount = registrationFee[_reporter].amount;

        registrationFee[_reporter].amount = 0;
        token.safeTransfer(_reporter, tempAmount);

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
    * @dev 신고자의 블락 기간을 조회한다
    * @param _reporter 확인 할 대상
    */
    function getReporterBlockTime(address _reporter) external view returns(uint256 blockTime_) {
        return registrationFee[_reporter].blockTime;
    }

    event RegistrationFee(address _from, uint256 _value, address _token);
    event SendReport(uint256 indexed id, address indexed _content, address indexed _from, string _detail);
    event WithdrawRegistration(address _to, uint256 _amount);
    event CompleteReport(uint256 _index, string _detail, bool _valid, uint256 _resultAmount);
    event Deduction(address _reporter, uint256 _amount);
    event ReporterBlock(address _reporter, uint256 _blockTime);

}
