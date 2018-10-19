pragma solidity ^0.4.24;

contract IContentsManager {
    function getContentsAddress() external view returns (address[] contentsAddress_);
    function getWriterContentsAddress(address _writer) external view returns (address[] writerContentsAddress_);
    function getInitialDeposit(address _writer) external view returns (uint256 initialDeposit_);
    function getPublishContentsAddress() external view returns (address[] contentsAddress_);
    function addContents(address _writer, string _writerName, string _record) external;
    event ContentInitialDeposit(address indexed _writer, uint256 _amount);
    event TransferInitialDeposit(address indexed _writer, address indexed _content, uint256 _value);
    event RegisterContents(uint256 indexed _contentsIndexId, address indexed _contentsAddress, address indexed _writerAddress, string _writerName, string _record);
}
