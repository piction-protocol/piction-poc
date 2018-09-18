pragma solidity ^0.4.24;

interface IReport {
    function completeReport(uint256 _index, bool _valid, uint256 _resultAmount) external;
    function deduction(address _reporter, uint256 _rate, bool _block) external returns(uint256);
    function getReportCount(address _content) external view returns(uint256);
    function getUncompletedReport(address _content) external view returns(uint256 count);
    function getReport(uint256 _index) external view returns(address content, address reporter, string detail, bool complete, bool completeValid, uint256 completeAmount);
}
