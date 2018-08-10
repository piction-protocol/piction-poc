pragma solidity ^0.4.24;

import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/council/CouncilInterface.sol";

import "contracts/report/ReportInterface.sol";
import "contracts/deposit/DepositPoolInterface.sol";

/**
 * @title Council contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Council is ExtendsOwnable, ValidValue, CouncilInterface {

    struct PictionValue {
        uint256 initialDeposit;
        uint256 reportRegistrationFee;
    }

    struct PictionRate {
        uint256 cdRate;
        uint256 depositRate;
        uint256 userPaybackRate;
        uint256 reportRewardRate;
        uint256 marketerDefaultRate;
    }

    struct PictionAddress {
        address userPaybackPool;
        address depositPool;
        address pixelDistributor;
        address marketer;
        address report;
    }

    struct ManagerAddress {
        address roleManager;
        address contentsManager;
        address fundManager;
        address accountManager;
    }

    address token;
    PictionValue pictionValue;
    PictionRate pictionRate;
    PictionAddress pictionAddress;
    ManagerAddress managerAddress;

    constructor(
        address _token)
        public
        validAddress(_token)
    {
        token = _token;

        emit RegisterCouncil(msg.sender, _token);
    }

    function initialValue(
        uint256 _initialDeposit,
        uint256 _reportRegistrationFee)
        external onlyOwner
        validRange(_initialDeposit)
        validRange(_reportRegistrationFee) {

        pictionValue = PictionValue(_initialDeposit, _reportRegistrationFee);

        emit InitialValue(_initialDeposit, _reportRegistrationFee);
    }

    function initialRate(
        uint256 _cdRate,
        uint256 _depositRate,
        uint256 _userPaybackRate,
        uint256 _reportRewardRate,
        uint256 _marketerDefaultRate)
        external onlyOwner
        validRange(_cdRate)
        validRange(_depositRate)
        validRange(_userPaybackRate)
        validRange(_reportRewardRate)
        validRange(_marketerDefaultRate) {

        pictionRate = PictionRate(_cdRate, _depositRate, _userPaybackRate, _reportRewardRate, _marketerDefaultRate);

        emit InitialRate(_cdRate, _depositRate, _userPaybackRate, _reportRewardRate, _marketerDefaultRate);
    }

    function initialPictionAddress(
        address _userPaybackPool,
        address _depositPool,
        address _pixelDistributor,
        address _marketer,
        address _report)
        external onlyOwner
        validAddress(_userPaybackPool)
        validAddress(_depositPool)
        validAddress(_pixelDistributor)
        validAddress(_marketer)
        validAddress(_report) {

        pictionAddress = PictionAddress(_userPaybackPool, _depositPool, _pixelDistributor, _marketer, _report);

        emit InitialAddress(_userPaybackPool, _depositPool, _pixelDistributor, _marketer, _report);
    }

    function initialManagerAddress(
        address _roleManager,
        address _contentsManager,
        address _fundManager,
        address _accountManager)
        external onlyOwner
        validAddress(_roleManager)
        validAddress(_contentsManager)
        validAddress(_fundManager)
        validAddress(_accountManager)
    {

        managerAddress = ManagerAddress(_roleManager, _contentsManager, _fundManager, _accountManager);

        emit InitialManagerAddress(_roleManager, _contentsManager, _fundManager, _accountManager);
    }

    /**
    * @dev Report 목록의 신고를 처리함
    * @param _index Report의 reports 인덱스 값
    * @param _content Content의 주소
    * @param _reporter Reporter의 주소
    * @param _deductionRate 신고자의 RegFee를 차감시킬 비율, 0이면 Reward를 지급함, 50(논의)이상이면 block처리함
    */
    function judge(uint256 _index, address _content, address _reporter, uint256 _deductionRate)
        external
        onlyOwner
        validAddress(_content)
        validAddress(_reporter)
    {
        if (_deductionRate > 0) {
            ReportInterface(pictionAddress.report).deduction(_reporter, _deductionRate, (_deductionRate/(10 ** 16)) >= 50 ? true:false);
        } else {
            DepositPoolInterface(pictionAddress.depositPool).reportReward(_content, _reporter);
        }

        ReportInterface(pictionAddress.report).completeReport(_index);

        emit Judge(_index, _content, _reporter, _deductionRate);
    }


    function getToken() external view returns (address) {
        return token;
    }

    function setInitialDeposit(uint256 _initialDeposit) external onlyOwner validRange(_initialDeposit) {
        pictionValue.initialDeposit = _initialDeposit;

        emit ChangeDistributionRate(msg.sender, "initial deposit", _initialDeposit);
    }

    function getInitialDeposit() external view returns (uint256) {
        return pictionValue.initialDeposit;
    }

    function setReportRegistrationFee(uint256 _reportRegistrationFee) external onlyOwner validRange(_reportRegistrationFee) {
        pictionValue.reportRegistrationFee = _reportRegistrationFee;

        emit ChangeDistributionRate(msg.sender, "report registration fee", _reportRegistrationFee);
    }

    function getReportRegistrationFee() view external returns (uint256) {
        return pictionValue.reportRegistrationFee;
    }

    function setCdRate(uint256 _cdRate) external onlyOwner validRange(_cdRate) {
        pictionRate.cdRate = _cdRate;

        emit ChangeDistributionRate(msg.sender, "cd rate", _cdRate);
    }

    function getCdRate() external view returns (uint256) {
        return pictionRate.cdRate;
    }

    function setDepositRate(uint256 _depositRate) external onlyOwner validRange(_depositRate) {
        pictionRate.depositRate = _depositRate;

        emit ChangeDistributionRate(msg.sender, "deposit rate", _depositRate);
    }

    function getDepositRate() external view returns (uint256) {
        return pictionRate.depositRate;
    }

    function setUserPaybackRate(uint256 _userPaybackRate) external onlyOwner validRange(_userPaybackRate) {
        pictionRate.userPaybackRate = _userPaybackRate;

        emit ChangeDistributionRate(msg.sender, "user payback rate", _userPaybackRate);
    }

    function getUserPaybackRate() external view returns (uint256) {
        return pictionRate.userPaybackRate;
    }

    function setReportRewardRate(uint256 _reportRewardRate) external onlyOwner validRange(_reportRewardRate) {
        pictionRate.reportRewardRate = _reportRewardRate;

        emit ChangeDistributionRate(msg.sender, "report reward rate", _reportRewardRate);
    }

    function getReportRewardRate() view external returns (uint256) {
        return pictionRate.reportRewardRate;
    }

    function setMarketerDefaultRate(uint256 _marketerDefaultRate) external onlyOwner validRange(_marketerDefaultRate) {
        pictionRate.marketerDefaultRate = _marketerDefaultRate;

        emit ChangeDistributionRate(msg.sender, "marketer default rate", _marketerDefaultRate);
    }

    function getMarketerDefaultRate() view external returns (uint256) {
        return pictionRate.marketerDefaultRate;
    }

    function setUserPaybackPool(address _userPaybackPool) external onlyOwner validAddress(_userPaybackPool) {
        pictionAddress.userPaybackPool = _userPaybackPool;

        emit ChangeAddress(msg.sender, "user payback pool", _userPaybackPool);
    }

    function getUserPaybackPool() external view returns (address) {
        return pictionAddress.userPaybackPool;
    }

    function setDepositPool(address _depositPool) external onlyOwner validAddress(_depositPool) {
        pictionAddress.depositPool = _depositPool;

        emit ChangeAddress(msg.sender, "deposit pool", _depositPool);
    }

    function getDepositPool() external view returns (address) {
        return pictionAddress.depositPool;
    }

    function setRoleManager(address _roleManager) external onlyOwner validAddress(_roleManager) {
        managerAddress.roleManager = _roleManager;

        emit ChangeAddress(msg.sender, "role manager", _roleManager);
    }

    function getRoleManager() external view returns (address) {
        return managerAddress.roleManager;
    }

    function setContentsManager(address _contentsManager) external onlyOwner validAddress(_contentsManager) {
        managerAddress.contentsManager = _contentsManager;

        emit ChangeAddress(msg.sender, "contents manager", _contentsManager);
    }

    function getContentsManager() external view returns (address) {
        return managerAddress.contentsManager;
    }

    function setFundManager(address _fundManager) external onlyOwner validAddress(_fundManager) {
        managerAddress.fundManager = _fundManager;

        emit ChangeAddress(msg.sender, "fund manager", _fundManager);
    }

    function getFundManager() external view returns (address) {
        return managerAddress.fundManager;
    }

    function setAccountManager(address _accountManager) external onlyOwner validAddress(_accountManager) {
        managerAddress.accountManager = _accountManager;

        emit ChangeAddress(msg.sender, "account manager", _accountManager);
    }

    function getAccountManager() external view returns (address) {
        return managerAddress.accountManager;
    }

    function setPixelDistributor(address _pixelDistributor) external onlyOwner validAddress(_pixelDistributor) {
        pictionAddress.pixelDistributor = _pixelDistributor;

        emit ChangeAddress(msg.sender, "pixel distributor", _pixelDistributor);
    }

    function getPixelDistributor() external view returns (address) {
        return pictionAddress.pixelDistributor;
    }

    function setMarketer(address _marketer) external onlyOwner validAddress(_marketer) {
        pictionAddress.marketer = _marketer;

        emit ChangeAddress(msg.sender, "marketer", _marketer);
    }

    function getMarketer() external view returns (address) {
        return pictionAddress.marketer;
    }

    function setReport(address _report) external onlyOwner validAddress(_report) {
        pictionAddress.report = _report;

        emit ChangeAddress(msg.sender, "report", _report);
    }

    function getReport() external view returns (address) {
        return pictionAddress.report;
    }

    event RegisterCouncil(address _sender, address _token);
    event InitialValue(uint256 _depositRate, uint256 _reportRegistrationFee);
    event InitialRate(uint256 _cdRate, uint256 _initialDeposit, uint256 _userPaybackRate, uint256 _reportRewardRate, uint256 _marketerDefaultRate);
    event InitialAddress(address _userPaybackPool, address _depositPool, address _pixelDistributor, address _marketer, address _report);
    event InitialManagerAddress(address _depositPool, address _roleManager, address _contentsManager, address _accountManager);
    event ChangeDistributionRate(address _sender, string _name, uint256 _value);
    event ChangeAddress(address _sender, string addressName, address _addr);
    event Judge(uint256 _index, address _content, address _reporter, uint256 _deductionRate);
}
