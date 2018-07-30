pragma solidity ^0.4.24;

import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/council/CouncilInterface.sol";

/**
 * @title Council contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Council is ExtendsOwnable, ValidValue, CouncilInterface {
    uint256 cdRate;
    uint256 depositRate;
    uint256 initialDeposit;
    uint256 userPaybackRate;
    uint256 reportRegistrationFee;
    uint256 reportRewardRate;
    uint256 marketerDefaultRate;
    address userPaybackPool;
    address depositPool;
    address token;
    address roleManager;
    address contentsManager;
    address fundManager;
    address pixelDistributor;
    address marketer;

    constructor(
        uint256 _cdRate,
        uint256 _depositRate,
        uint256 _initialDeposit,
        uint256 _userPaybackRate,
        uint256 _reportRegistrationFee,
        uint256 _reportRewardRate,
        uint256 _marketerDefaultRate,
        address _token)
        public
        validRange(_cdRate)
        validRange(_depositRate)
        validRange(_initialDeposit)
        validRange(_userPaybackRate)
        validRange(_reportRegistrationFee)
        validRange(_reportRewardRate)
        validRange(_marketerDefaultRate)
        validAddress(_token)
    {
        cdRate = _cdRate;
        depositRate = _depositRate;
        initialDeposit = _initialDeposit;
        userPaybackRate = _userPaybackRate;
        reportRegistrationFee = _reportRegistrationFee;
        reportRewardRate = _reportRewardRate;
        marketerDefaultRate = _marketerDefaultRate;
        token = _token;

        emit RegisterCouncil(msg.sender, _cdRate, _depositRate, _initialDeposit, _userPaybackRate, _reportRegistrationFee, _reportRewardRate, _marketerDefaultRate, _token);
    }

    function setCdRate(uint256 _cdRate) external onlyOwner validRange(_cdRate) {
        cdRate = _cdRate;

        emit ChangeDistributionRate(msg.sender, "cd rate", _cdRate);
    }

    function getCdRate() external view returns (uint256) {
        return cdRate;
    }

    function setDepositRate(uint256 _depositRate) external onlyOwner validRange(_depositRate) {
        depositRate = _depositRate;

        emit ChangeDistributionRate(msg.sender, "deposit rate", _depositRate);
    }

    function getDepositRate() external view returns (uint256) {
        return depositRate;
    }

    function setInitialDeposit(uint256 _initialDeposit) external onlyOwner validRange(_initialDeposit) {
        initialDeposit = _initialDeposit;

        emit ChangeDistributionRate(msg.sender, "initial deposit", _initialDeposit);
    }

    function getInitialDeposit() external view returns (uint256) {
        return initialDeposit;
    }

    function setUserPaybackRate(uint256 _userPaybackRate) external onlyOwner validRange(_userPaybackRate) {
        userPaybackRate = _userPaybackRate;

        emit ChangeDistributionRate(msg.sender, "user payback rate", _userPaybackRate);
    }

    function getUserPaybackRate() external view returns (uint256) {
        return userPaybackRate;
    }

    function setReportRegistrationFee(uint256 _reportRegistrationFee) external onlyOwner validRange(_reportRegistrationFee) {
        reportRegistrationFee = _reportRegistrationFee;

        emit ChangeDistributionRate(msg.sender, "report registration fee", _reportRegistrationFee);
    }

    function getReportRegistrationFee() view external returns (uint256) {
        return reportRegistrationFee;
    }

    function setReportRewardRate(uint256 _reportRewardRate) external onlyOwner validRange(_reportRewardRate) {
        reportRewardRate = _reportRewardRate;

        emit ChangeDistributionRate(msg.sender, "report reward rate", _reportRewardRate);
    }

    function getReportRewardRate() view external returns (uint256) {
        return reportRewardRate;
    }

    function setMarketerDefaultRate(uint256 _marketerDefaultRate) external onlyOwner validRange(_marketerDefaultRate) {
        marketerDefaultRate = _marketerDefaultRate;

        emit ChangeDistributionRate(msg.sender, "marketer default rate", _marketerDefaultRate);
    }

    function getMarketerDefaultRate() view external returns (uint256) {
        return marketerDefaultRate;
    }

    function setUserPaybackPool(address _userPaybackPool) external onlyOwner validAddress(_userPaybackPool) {
        userPaybackPool = _userPaybackPool;

        emit ChangeAddress(msg.sender, "user payback pool", _userPaybackPool);
    }

    function getUserPaybackPool() external view returns (address) {
        return userPaybackPool;
    }

    function setDepositPool(address _depositPool) external onlyOwner validAddress(_depositPool) {
        depositPool = _depositPool;

        emit ChangeAddress(msg.sender, "deposit pool", _depositPool);
    }

    function getDepositPool() external view returns (address) {
        return depositPool;
    }

    function getToken() external view returns (address) {
        return token;
    }

    function setRoleManager(address _roleManager) external onlyOwner validAddress(_roleManager) {
        roleManager = _roleManager;

        emit ChangeAddress(msg.sender, "role manager", _roleManager);
    }

    function getRoleManager() external view returns (address) {
        return roleManager;
    }

    function setContentsManager(address _contentsManager) external onlyOwner validAddress(_contentsManager) {
        contentsManager = _contentsManager;

        emit ChangeAddress(msg.sender, "contents manager", _contentsManager);
    }

    function getContentsManager() external view returns (address) {
        return contentsManager;
    }

    function setFundManager(address _fundManager) external onlyOwner validAddress(_fundManager) {
        fundManager = _fundManager;

        emit ChangeAddress(msg.sender, "fund manager", _fundManager);
    }

    function getFundManager() external view returns (address) {
        return fundManager;
    }

    function setPixelDistributor(address _pixelDistributor) external onlyOwner validAddress(_pixelDistributor) {
        pixelDistributor = _pixelDistributor;

        emit ChangeAddress(msg.sender, "pixel distributor", _pixelDistributor);
    }

    function getPixelDistributor() external view returns (address) {
        return pixelDistributor;
    }

    function setMarketer(address _marketer) external onlyOwner validAddress(_marketer) {
        marketer = _marketer;

        emit ChangeAddress(msg.sender, "marketer", _marketer);
    }

    function getMarketer() external view returns (address) {
        return marketer;
    }

    event RegisterCouncil(address _sender, uint256 _cdRate, uint256 _deposit, uint256 _initialDeposit, uint256 _userPaybackRate, uint256 _reportRegistrationFee, uint256 _reportRewardRate, uint256 _marketerDefaultRate, address _token);
    event ChangeDistributionRate(address _sender, string _name, uint256 _value);
    event ChangeAddress(address _sender, string addressName, address _addr);
}
