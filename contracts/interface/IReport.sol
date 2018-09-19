pragma solidity ^0.4.24;

interface IReport {
    function sendReport(address _content, address reporter, string _detail) external;
    function getReport(uint256 _index) external view returns(address content_, address reporter_, string detail_, bool complete_, bool completeValid_, uint256 completeAmount_);
    function getRegistrationAmount(address _reporter) external view returns(uint256 amount_);
    function getRegistrationLockTime(address _reporter) external view returns(uint256 lockTime_);
    function getReporterBlockTime(address _reporter) external view returns(uint256 blockTime_);
    function withdrawRegistration(address _reporter) external;

    function completeReport(uint256 _index, bool _valid, uint256 _resultAmount) external;
    function deduction(address _reporter, uint256 _rate, bool _block) external returns(uint256 result_);
    function getReportCount(address _content) external view returns(uint256);
    function getUncompletedReport(address _content) external view returns(uint256 count);
}
