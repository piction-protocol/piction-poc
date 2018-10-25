pragma solidity ^0.4.24;

contract ICouncil {
    function getPictionConfig() external view returns (address pxlAddress_, uint256[] pictionValue_, uint256[] pictionRate_, address[] pictionAddress_, address[] managerAddress_, address[] apiAddress_, bool fundAvailable_);
    function getCdRate() external view returns (uint256 cdRate_);
    function getInitialDeposit() external view returns (uint256 initialDeposit_);
    function getDepositReleaseDelay() external view returns (uint256 depositReleaseDelay_);
    function getFundAvailable() external view returns (bool fundAvailable_);
    function getUserPaybackRate() external view returns (uint256 userPaybackRate_);
    function getReportRegistrationFee() view external returns (uint256 reportRegistrationFee_);
    function getUserPaybackPool() external view returns (address userPaybackPool_);
    function getDepositPool() external view returns (address depositPool_);
    function getSupporterPool() external view returns (address supporterPool_);
    function getToken() external view returns (address token_);
    function getContentsManager() external view returns (address contentsManager_);
    function getFundManager() external view returns (address fundManager_);
    function getAccountManager() external view returns (address accountManager_);
    function getPixelDistributor() external view returns (address pixelDistributor_);
    function getReport() external view returns (address report_);
    function getContentsDistributor() external view returns (address contentsDistributor_);
    function getApiContents() external view returns (address apiContents_);
    function getApiReport() external view returns (address apiReport_);
    function getApiFund() external view returns (address apiFund_);
    function setMember(address _member, bool _allow) external;
    function isMember(address _member) external view returns(bool allow_);
    function reportDisposal(uint256 _index, address _content, address _reporter, uint256 _type, string _description) external returns (uint256 deductionAmount_);
    function contentBlocking(address _contentAddress, bool _isBlocked) public;

    event RegisterCouncil(address _sender, address _token);
    event InitialValue(uint256 _depositRate, uint256 _reportRegistrationFee, uint256 _depositReleaseDelay, bool _fundAvailable);
    event InitialRate(uint256 _cdRate, uint256 _userPaybackRate);
    event InitialAddress(address _userPaybackPool, address _depositPool, address _supporterPool, address _pixelDistributor, address _report, address _contentsDistributor);
    event InitialManagerAddress(address _depositPool, address _contentsManager, address _accountManager);
    event InitialApiAddress(address _apiContents, address _apiReport, address _apiFund);
    event ReportDisposal(uint256 _date, uint256 _index, address indexed _content, address indexed _reporter, uint256 _type, string _description, uint256 _deductionAmount);
    event SetMember(address _member, bool _allow);
    event ContentBlocking(address indexed _sender, address indexed _contentAddress, bool _isBlocked);
}
