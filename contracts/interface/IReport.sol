pragma solidity ^0.4.24;

interface IReport {
    function sendReport(address _content, address reporter, string _detail) external;
    function getReport(uint256 _index) external view returns(uint256 reportDate_, address content_, address reporter_, string detail_, uint256 completeDate_, uint256 completeType_, uint256 completeAmount_);
    function getRegistrationAmount(address _reporter) external view returns(uint256 amount_);
    function getRegistrationLockTime(address _reporter) external view returns(uint256 lockTime_);
    function getReporterBlock(address _reporter) external view returns(bool isBlock_);
    function withdrawRegistration(address _reporter) external;
    function getUncompletedReportCount(address _content) external view returns(uint256 count_);

    function completeReport(uint256 _index, uint256 _type, uint256 _deductionAmount) external;
    function deduction(address _reporter) external returns(uint256 result_);
    function getReportCount(address _content) external view returns(uint256 count_);
}
