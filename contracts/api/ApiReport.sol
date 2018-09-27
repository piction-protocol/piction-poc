pragma solidity ^0.4.24;

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IReport.sol";

import "contracts/utils/ValidValue.sol";

contract ApiReport is ValidValue {

    //위원회
    ICouncil council;

    constructor(address _councilAddress) public validAddress(_councilAddress) {
        council = ICouncil(_councilAddress);
    }

    //-------- 등록금 관련 --------

    /**
    * @dev 신고자가 맞긴 보증금을 찾아감
    */
    function withdrawRegistration() external {
        return IReport(council.getReport()).withdrawRegistration(msg.sender);
    }

    /**
    * @dev 신고자가 맞긴 신고 보증금 잔액과 잠금 기간, 블락 기간을 조회한다
    */
    function getRegistrationAmount() external view returns(uint256 amount_, uint256 lockTime_, uint256 blockTime_) {
        IReport report = IReport(council.getReport());
        return (
            report.getRegistrationAmount(msg.sender),
            report.getRegistrationLockTime(msg.sender),
            report.getReporterBlockTime(msg.sender)
        );
    }

    //-------- 신고 관련 --------

    /**
    * @dev 신고자가 어떤 작품에 대해 신고를 함
    * @param _content 신고 할 작품 주소
    * @param _detail 신고정보
    */
    function sendReport(address _content, string _detail) external validAddress(_content) {
        IReport(council.getReport()).sendReport(_content, msg.sender, _detail);
    }

    /**
    * @dev 문제가 있는 신고자 처리
    * @param _reporter 막을 대상
    * @param _deduction 신고자 보증금 차감
    * @param _block 신고자 추가 신고 막음
    */
    function reporterJudge(address _reporter, bool _deduction, bool _block) external validAddress(_reporter) {
        require(council.isMember(msg.sender));
        if (_deduction) {
            council.reporterDeduction(_reporter);
        }

        if (_block) {
            council.reporterBlock(_reporter);
        }
    }

    /**
    * @dev Report 목록의 신고를 처리함
    * @param _index Report의 reports 인덱스 값
    * @param _content Content의 주소
    * @param _reporter Reporter의 주소
    * @param _reword 리워드 지급 여부
    */
    function reportProcess(uint256 _index, address _content, address _reporter, bool _reword) external validAddress(_reporter) {
        require(council.isMember(msg.sender));
        council.reportReword(_index, _content, _reporter, _reword);
    }

    /**
    * @dev 신고 목록의 id 값으로 처리여부, 보상 토큰량을 회신함
    * @param ids 신고 id 목록
    */
    function getReportResult(uint256[] ids)
        external
        view
        returns(bool[] memory complete_, uint256[] memory completeAmount_)
    {
        complete_ = new bool[](ids.length);
        completeAmount_ = new uint256[](ids.length);

        for(uint i = 0; i < ids.length; i++) {
            (,,,complete_[i],, completeAmount_[i]) = IReport(council.getReport()).getReport(ids[i]);
        }
    }
}
