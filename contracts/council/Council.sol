pragma solidity ^0.4.24;

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IReport.sol";
import "contracts/interface/IContent.sol";
import "contracts/interface/IDepositPool.sol";

import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";

/**
 * @title Council contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Council is ExtendsOwnable, ValidValue, ICouncil {

    struct PictionValue {
        uint256 initialDeposit;
        uint256 reportRegistrationFee;
        uint256 depositReleaseDelay;
        bool fundAvailable;
    }

    struct PictionRate {
        uint256 cdRate;
        uint256 userPaybackRate;
        uint256 reportRewardRate;
    }

    struct PictionAddress {
        address userPaybackPool;
        address depositPool;
        address supporterPool;
        address pixelDistributor;
        address report;
        address contentsDistributor;
    }

    struct ManagerAddress {
        address contentsManager;
        address fundManager;
        address accountManager;
    }

    struct ApiAddress {
        address apiContents;
        address apiReport;
        address apiFund;
    }

    address token;
    PictionValue pictionValue;
    PictionRate pictionRate;
    PictionAddress pictionAddress;
    ManagerAddress managerAddress;
    ApiAddress apiAddress;

    mapping (address => bool) members;

    constructor(
        address _token)
        public
        validAddress(_token)
    {
        token = _token;
        members[msg.sender] = true;

        emit RegisterCouncil(msg.sender, _token);
    }

    function setMember(address _member, bool _allow) external onlyOwner {
        members[_member] = _allow;

        emit SetMember(_member, _allow);
    }

    function isMember(address _member) external view returns(bool allow_) {
        allow_ = members[_member];
    }

    function initialValue(
        uint256 _initialDeposit,
        uint256 _reportRegistrationFee,
        uint256 _depositReleaseDelay,
        bool _fundAvailable)
        external onlyOwner
        validRange(_initialDeposit)
        validRange(_reportRegistrationFee) {

        pictionValue = PictionValue(_initialDeposit, _reportRegistrationFee, _depositReleaseDelay, _fundAvailable);

        emit InitialValue(_initialDeposit, _reportRegistrationFee, _depositReleaseDelay, _fundAvailable);
    }

    function initialRate(
        uint256 _cdRate,
        uint256 _userPaybackRate,
        uint256 _reportRewardRate)
        external onlyOwner
    {

        pictionRate = PictionRate(_cdRate, _userPaybackRate, _reportRewardRate);

        emit InitialRate(_cdRate, _userPaybackRate, _reportRewardRate);
    }

    function initialPictionAddress(
        address _userPaybackPool,
        address _depositPool,
        address _supporterPool,
        address _pixelDistributor,
        address _report,
        address _contentsDistributor)
        external onlyOwner
        validAddress(_userPaybackPool)
        validAddress(_depositPool)
        validAddress(_supporterPool)
        validAddress(_pixelDistributor)
        validAddress(_report) 
        validAddress(_contentsDistributor)
    {
        pictionAddress = PictionAddress(_userPaybackPool, _depositPool, _supporterPool, _pixelDistributor, _report, _contentsDistributor);

        emit InitialAddress(_userPaybackPool, _depositPool, _supporterPool, _pixelDistributor, _report, _contentsDistributor);
    }

    function initialManagerAddress(
        address _contentsManager,
        address _fundManager,
        address _accountManager)
        external onlyOwner
        validAddress(_contentsManager)
        validAddress(_fundManager)
        validAddress(_accountManager)
    {

        managerAddress = ManagerAddress(_contentsManager, _fundManager, _accountManager);

        emit InitialManagerAddress(_contentsManager, _fundManager, _accountManager);
    }

    function initialApiAddress(
        address _apiContents,
        address _apiReport,
        address _apiFund
    )
        external
        onlyOwner
        validAddress(_apiContents) validAddress(_apiReport) validAddress(_apiFund)
    {
        apiAddress = ApiAddress(_apiContents, _apiReport, _apiFund);

        emit InitialApiAddress(_apiContents, _apiReport, _apiFund);
    }

    /**
    * @dev 위원회 등록된 전체 정보 조회
    * @return address pxlAddress_ pxl token address
    * @return uint256[] pictionValue_ 상황 별 deposit token 수량
    * @return uint256[] pictionRate_ 작품 판매시 분배 될 고정 비율 정보
    * @return address[] pictionAddress_ piction network에서 사용되는 컨트랙트 주소
    * @return address[] managerAddress_ 매니저 성격의 컨트랙트 주소
    * @return address[] apiAddress_ piction network API 컨트랙트 주소
    * @return bool fundAvailable_ piction network 투자 기능 사용 여부
    */
    function getPictionConfig()
        external
        view
        returns (address pxlAddress_, uint256[] pictionValue_, uint256[] pictionRate_,
             address[] pictionAddress_, address[] managerAddress_, address[] apiAddress_, bool fundAvailable_)
    {
        pictionValue_ = new uint256[](3);
        pictionRate_ = new uint256[](3);
        pictionAddress_ = new address[](5);
        managerAddress_ = new address[](3);
        apiAddress_ = new address[](3);

        pxlAddress_ = token;

        // 배열의 순서는 구조체 선언 순서
        pictionValue_[0] = pictionValue.initialDeposit;
        pictionValue_[1] = pictionValue.reportRegistrationFee;
        pictionValue_[2] = pictionValue.depositReleaseDelay;

        pictionRate_[0] = pictionRate.cdRate;
        pictionRate_[1] = pictionRate.userPaybackRate;
        pictionRate_[2] = pictionRate.reportRewardRate;

        pictionAddress_[0] = pictionAddress.userPaybackPool;
        pictionAddress_[1] = pictionAddress.depositPool;
        pictionAddress_[2] = pictionAddress.pixelDistributor;
        pictionAddress_[3] = pictionAddress.report;
        pictionAddress_[4] = pictionAddress.contentsDistributor;

        managerAddress_[0] = managerAddress.contentsManager;
        managerAddress_[1] = managerAddress.fundManager;
        managerAddress_[2] = managerAddress.accountManager;

        apiAddress_[0] = apiAddress.apiContents;
        apiAddress_[1] = apiAddress.apiReport;
        apiAddress_[2] = apiAddress.apiFund;

        fundAvailable_ = pictionValue.fundAvailable;
    }

    /**
    * @dev 정당하지 않은 신고한 유저의 보증금 차감
    * @param _reporter 신고자 주소
    */
    // function reporterDeduction(address _reporter) external {
    //     require(apiAddress.apiReport == msg.sender);

    //     uint256 deductionAmount;
    //     deductionAmount = IReport(pictionAddress.report).deduction(_reporter);

    //     emit ReporterDeduction(_reporter, deductionAmount);
    // }

    /**
    * @dev 정당하지 않은 신고한 유저의 블락
    * @param _reporter 신고자 주소
    */
    // function reporterBlock(address _reporter) external {
    //     require(apiAddress.apiReport == msg.sender);

    //     IReport(pictionAddress.report).reporterBlock(_reporter);

    //     emit ReporterBlock(_reporter);
    // }

    /**
    * @dev Report 목록의 신고를 처리함
    * @param _index Report의 reports 인덱스 값
    * @param _content Content의 주소
    * @param _reporter Reporter의 주소
    * @param _reword 리워드 지급 여부
    */
    // function reportReword(uint256 _index, address _content, address _reporter, bool _reword) external {
    //     require(apiAddress.apiReport == msg.sender);

    //     uint256 rewordAmount;
    //     if (_reword) {
    //         rewordAmount = IDepositPool(pictionAddress.depositPool).reportReward(_content, _reporter);
    //     }

    //     IReport(pictionAddress.report).completeReport(_index, _reword, rewordAmount);

    //     emit ReportReword(_index, _content, _reporter, _reword, rewordAmount);
    // }

    enum ReportDisposalType {CONTENT_BLOCK, WARNS_WRITER, PASS, DUPLICATE, WRONG_REPORT}

    /**
    * @dev 신고 목록을 처리함
    * @param _index Report 인덱스 값
    * @param _content 작품의 주소
    * @param _reporter 신고자의 주소
    * @param _type 처리 타입 : 0 작품 차단, 1 작가 경고, 2 신고 무효, 3 중복 신고, 4 잘못된 신고
    */
    function reportDisposal(uint256 _index, address _content, address _reporter, uint256 _type, string _description) external {
        require(apiAddress.apiReport == msg.sender, "msg sender is not apiReport");

        uint256 deductionAmount;

        if (_type == uint256(ReportDisposalType.CONTENT_BLOCK)) {
            contentBlocking(_content, true);
            //diposit 모두 차감, 리워드 1 지급
            
            //리포트 처리 완료 type 넘김
            //IReport(pictionAddress.report).completeReport(_index, _reword, rewordAmount);
        } else if (_type == uint256(ReportDisposalType.WARNS_WRITER)) {
            //diposit 1차감 , 리워드 1 지급

            //리포트 처리 완료 type 넘김
            //IReport(pictionAddress.report).completeReport(_index, _reword, rewordAmount);
        } else if ((_type == uint256(ReportDisposalType.PASS)) || (_type == uint256(ReportDisposalType.DUPLICATE))) {
            //리포트 처리 완료 type 넘김
            //IReport(pictionAddress.report).completeReport(_index, _reword, rewordAmount);
        } else if (_type == uint256(ReportDisposalType.WRONG_REPORT)) {
            //신고 예치금 1차감, 카운실 1전송
            
            //리포트 처리 완료 type 넘김
            //IReport(pictionAddress.report).completeReport(_index, _reword, rewordAmount);
        }

        emit ReportDisposal(TimeLib.currentTime(), _index, _content, _reporter, _type, _description, deductionAmount);
    }

    function contentBlocking(address _contentAddress, bool _isBlocked) public {
        require(apiAddress.apiReport == msg.sender || members[msg.sender], "Content blocking failed : access denied");

        IContent(_contentAddress).setIsBlocked(_isBlocked);
        emit ContentBlocking(msg.sender, _contentAddress, _isBlocked);
    }

    function getToken() external view returns (address token_) {
        return token;
    }

    function getInitialDeposit() external view returns (uint256 initialDeposit_) {
        return pictionValue.initialDeposit;
    }

    function getReportRegistrationFee() view external returns (uint256 reportRegistrationFee_) {
        return pictionValue.reportRegistrationFee;
    }

    function getDepositReleaseDelay() external view returns (uint256 depositReleaseDelay_) {
        return pictionValue.depositReleaseDelay;
    }

    function getFundAvailable() external view returns (bool fundAvailable_) {
        return pictionValue.fundAvailable;
    }

    function getCdRate() external view returns (uint256 cdRate_) {
        return pictionRate.cdRate;
    }

    function getUserPaybackRate() external view returns (uint256 userPaybackRate_) {
        return pictionRate.userPaybackRate;
    }

    function getReportRewardRate() view external returns (uint256 reportRewardRate_) {
        return pictionRate.reportRewardRate;
    }

    function getUserPaybackPool() external view returns (address userPaybackPool_) {
        return pictionAddress.userPaybackPool;
    }

    function getDepositPool() external view returns (address depositPool_) {
        return pictionAddress.depositPool;
    }

    function getSupporterPool() external view returns (address supporterPool_) {
        return pictionAddress.supporterPool;
    }

    function getContentsManager() external view returns (address contentsManager_) {
        return managerAddress.contentsManager;
    }

    function getFundManager() external view returns (address fundManager_) {
        return managerAddress.fundManager;
    }

    function getAccountManager() external view returns (address accountManager_) {
        return managerAddress.accountManager;
    }

    function getPixelDistributor() external view returns (address pixelDistributor_) {
        return pictionAddress.pixelDistributor;
    }

    function getReport() external view returns (address report_) {
        return pictionAddress.report;
    }

    function getContentsDistributor() external view returns (address contentsDistributor_) {
        return pictionAddress.contentsDistributor;
    }

    function getApiContents() external view returns (address apiContents_) {
        return apiAddress.apiContents;
    }

    function getApiReport() external view returns (address apiReport_) {
        return apiAddress.apiReport;
    }

    function getApiFund() external view returns (address apiFund_) {
        return apiAddress.apiFund;
    }
}
