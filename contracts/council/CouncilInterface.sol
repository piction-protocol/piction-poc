pragma solidity ^0.4.24;

interface CouncilInterface {
    function getCdRate() external view returns (uint256);
    function getDepositRate() external view returns (uint256);
    function getInitialDeposit() external view returns (uint256);
    function getUserPaybackRate() external view returns (uint256);
    function getReportRegistrationFee() view external returns (uint256);
    function getReportRewardRate() view external returns (uint256);
    function getMarketerDefaultRate() view external returns (uint256);
    function getUserPaybackPool() external view returns (address);
    function getDepositPool() external view returns (address);
    function getToken() external view returns (address);
    function getRoleManager() external view returns (address);
    function getContentsManager() external view returns (address);
    function getFundManager() external view returns (address);
    function getPixelDistributor() external view returns (address);
    function getMarketer() external view returns (address);
    function getReport() external view returns (address);
}
