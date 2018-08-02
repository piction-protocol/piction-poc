pragma solidity ^0.4.24;

interface ReportInterface {
    function completeReport(uint256 _index) external;
    function deduction(address _reporter, uint256 _rate, bool _block) external;
    function getReportCount(address _content) external view returns(uint256);
}
