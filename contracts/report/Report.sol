pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/council/CouncilInterface.sol";

import "contracts/report/ReportInterface.sol";
import "contracts/deposit/DepositPoolInterface.sol";

import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";

contract Report is ExtendsOwnable, ValidValue, ContractReceiver, ReportInterface {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    uint256 DECIMALS = 10 ** 18;

    //위원회
    CouncilInterface council;

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
    uint256 interval = 30000; //for test

    //신고내용과 처리유무
    struct ReportData {
        address content;
        address reporter;
        string detail;
        bool complete;
    }
    //신고 목록
    ReportData[] reports;

    /**
    * @dev 생성자
    * @param _councilAddress 위원회 주소
    */
    constructor(address _councilAddress) public validAddress(_councilAddress) {
        council = CouncilInterface(_councilAddress);
    }

    /**
    * @dev Token의 ApproveAndCall이 호출하는 Contract의 함수
    * @param _from 토큰을 보내는 주소
    * @param _value 토큰의 양
    * @param _token 토큰의 주소
    * @param _jsonData 전달되는 데이터
    */
    function receiveApproval(address _from, uint256 _value, address _token, string _jsonData) public {
        addRegistrationFee(_from, _value, _token);
    }

    /**
    * @dev receiveApproval의 구현, token을 전송 받고 신고자의 등록금을 기록함
    */
    function addRegistrationFee(address _from, uint256 _value, address _token) private {
        require(council.getReportRegistrationFee() == _value);
        require(registrationFee[_from].amount == 0);
        ERC20 token = ERC20(council.getToken());
        require(address(token) == _token);

        registrationFee[_from].amount = _value;
        registrationFee[_from].lockTime = TimeLib.currentTime().add(interval);
        token.safeTransferFrom(_from, address(this), _value);

        emit AddRegistrationFee(_from, _value, _token);
    }

    /**
    * @dev 신고자가 어떤 작품에 대해 신고를 함, 위원회의 보증금 변경과 관계없이 동작함(추후 논의)
    * @param _detail 신고정보
    */
    function sendReport(address _content, string _detail)
        external
        validAddress(_content)
        validString(_detail)
    {
        require(registrationFee[msg.sender].amount > 0);
        require(registrationFee[msg.sender].blockTime < TimeLib.currentTime());

        reports.push(ReportData(_content, msg.sender, _detail, false));

        emit SendReport(msg.sender, _detail);
    }

    /**
    * @dev 신고한 내용을 가져옴 (String Array를 사용하지 못함으로 한건씩 조회 필요)
    * @param _index 신고 목록의 인덱스
    */
    function getReport(uint256 _index)
        external
        view
        returns(address content, address reporter, string detail, bool complete)
    {
        content = reports[_index].content;
        reporter = reports[_index].reporter;
        detail = reports[_index].detail;
        complete = reports[_index].complete;
    }

    /**
    * @dev 신고 목록의 길이
    */
    function getReportsLength() external view returns(uint256) {
        return reports.length;
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
    * @dev 작품의 신고 중 처리되지 않은 건수 조회
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
    * @dev 신고자의 신고 중 처리되지 않은 건수 조회
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
    */
    function completeReport(uint256 _index) external {
        require(msg.sender == address(council));
        require(_index < reports.length);
        require(!reports[_index].complete);

        reports[_index].complete = true;

        emit CompleteReport(_index, reports[_index].detail);
    }

    /**
    * @dev 신고자의 무효, 증거 불충분으로 인한 RegFee 차감, 위원회가 호출함
    * @param _reporter 차감 시킬 대상
    * @param _rate 차감 시킬 비율
    * @param _block 특정시간 행동 페널티를 줄것
    */
    function deduction(address _reporter, uint256 _rate, bool _block)
        external
        validAddress(_reporter)
        validRange(_rate)
        validRate(_rate)
    {
        require(msg.sender == address(council));
        require(registrationFee[_reporter].amount > 0);

        uint256 result = registrationFee[_reporter].amount.mul(_rate).div(DECIMALS);
        registrationFee[_reporter].amount = registrationFee[_reporter].amount.sub(result);

        ERC20 token = ERC20(council.getToken());
        //임시 Ecosystem Growth Fund가 없음으로 위원회로 전송함
        token.safeTransfer(address(council), result);

        if (_block) {
            registrationFee[_reporter].blockTime = registrationFee[_reporter].lockTime;
        }

        emit Deduction(_reporter, _rate, result, _block);
    }

    /**
    * @dev 신고자가 맞긴 보증금을 찾아감
    */
    function returnRegFee() external {
        require(registrationFee[msg.sender].amount > 0);
        require(registrationFee[msg.sender].lockTime < TimeLib.currentTime());
        require(getUncompletedReporter(msg.sender) == 0);

        ERC20 token = ERC20(council.getToken());
        uint256 tempAmount = registrationFee[msg.sender].amount;

        registrationFee[msg.sender].amount = 0;
        token.safeTransfer(msg.sender, tempAmount);

        emit ReturnRegFee(msg.sender, tempAmount);
    }

    /**
    * @dev 신고자가 자신이 맞긴 등록금을 확인
    */
    function getRegFee() external view returns(uint256, uint256, uint256) {
        return (registrationFee[msg.sender].amount,
            registrationFee[msg.sender].lockTime,
            registrationFee[msg.sender].blockTime);
    }

    event AddRegistrationFee(address _from, uint256 _value, address _token);
    event SendReport(address _from, string _detail);
    event ReturnRegFee(address _to, uint256 _amount);
    event CompleteReport(uint256 _index, string _detail);
    event Deduction(address _reporter, uint256 _rate, uint256 _amount, bool _block);

}
