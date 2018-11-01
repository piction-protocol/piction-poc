pragma solidity ^0.4.24;

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IReport.sol";

import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";

contract ApiReport is ValidValue {

    //위원회
    ICouncil council;

    constructor(address _councilAddress) public validAddress(_councilAddress) {
        council = ICouncil(_councilAddress);
    }

    //-------- 신고 등록금 관련 --------

    /**
    * @dev 신고자가 맞긴 보증금을 찾아감
    */
    function withdrawRegistration() external {
        return IReport(council.getReport()).withdrawRegistration(msg.sender);
    }

    /**
    * @dev 신고자가 맞긴 신고 보증금 잔액과 잠금 기간, 블락 유무을 조회한다
    */
    function getRegistrationAmount() external view returns(uint256 amount_, uint256 lockTime_, bool isBlock_) {
        IReport report = IReport(council.getReport());
        return (
            report.getRegistrationAmount(msg.sender),
            report.getRegistrationLockTime(msg.sender),
            report.getReporterBlock(msg.sender)
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
    * @dev 신고 목록을 처리함
    * @param _index Report 인덱스 값
    * @param _content 작품의 주소
    * @param _reporter 신고자의 주소
    * @param _type 처리 타입 : 1 작품 차단, 2 작가 경고, 3 신고 무효, 4 중복 신고, 5 잘못된 신고
    * @param _description 처리내역
    */
    function reportDisposal(uint256 _index, address _content, address _reporter, uint256 _type, string _description) 
        external 
        validAddress(_content)
        validAddress(_reporter)
    {
        require(council.isMember(msg.sender), "msg sender is not council member");
        require(_type > 0 && _type < 6, "out of type");

        uint256 deductionAmount;
        deductionAmount = council.reportDisposal(_index, _content, _reporter, _type, _description);
        emit ReportDisposal(TimeLib.currentTime(), _index, _content, _reporter, _type, _description, deductionAmount);
    }

    event ReportDisposal(uint256 _date, uint256 _index, address indexed _content, address indexed _reporter, uint256 _type, string _description, uint256 _deductionAmount);

    /**
    * @dev 신고 목록의 id 값으로 처리여부, 처리타입, 보상 토큰량을 회신함
    * @param ids 신고 id 목록
    */
    function getReportResult(uint256[] ids)
        external
        view
        returns(uint256[] memory completeDate_, uint256[] memory completeType_, uint256[] memory completeAmount_)
    {
        completeDate_ = new uint256[](ids.length);
        completeType_ = new uint256[](ids.length);
        completeAmount_ = new uint256[](ids.length);

        for(uint i = 0; i < ids.length; i++) {
            (,,,,completeDate_[i],completeType_[i], completeAmount_[i]) = IReport(council.getReport()).getReport(ids[i]);
        }
    }

    /**
    * @dev 작품의 신고 중 처리되지 않은 건수 조회
    * @param _content 확인할 작품의 주소
    */
    function getUncompletedReportCount(address _content) external view returns(uint256 count_) {
        return IReport(council.getReport()).getUncompletedReportCount(_content);
    }

    /**
    * @dev 작품들의 신고 중 처리되지 않은 건수 조회
    * @param _contents 확인할 작품들의 주소
    */
    function getUncompletedReportCounts(address[] _contents) external view returns(uint256[] memory counts_) {
        counts_ = new uint256[](_contents.length);

        for (uint256 i = 0; i < _contents.length; i++) {
            counts_[i] = IReport(council.getReport()).getUncompletedReportCount(_contents[i]);
        }
    }
}
