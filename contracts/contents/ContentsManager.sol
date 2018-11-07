pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/token/CustomToken.sol";
import "contracts/contents/Content.sol";

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IContentsManager.sol";

import "contracts/utils/ValidValue.sol";
import "contracts/utils/BytesLib.sol";

contract ContentsManager is IContentsManager, ContractReceiver, ValidValue {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping (address => uint256) initialDeposit;
    mapping (address => address[]) writerContents;

    address[] public contentsAddress;
    ICouncil council;
    IERC20 token;

    modifier validAccessAddress(address _apiAddress) {
        require(council.getApiContents() == _apiAddress, "Acces failed: Only Access to ApiContents smart contract.");
        _;
    }

    constructor(address _councilAddr)
        public
        validAddress(_councilAddr)
    {
        council = ICouncil(_councilAddr);
        token = IERC20(council.getToken());
    }

    function addContents(
        address _writer,
        string _writerName,
        string _record
    )
        external
        validAccessAddress(msg.sender)
    {
        require(council.getApiContents() == msg.sender, "Content creation failed: Only ApiContents contract.");

        address contractAddress = new Content(_record, _writer, _writerName, address(council));

        Content(contractAddress).transferOwnership(_writer);

        contentsAddress.push(contractAddress);
        writerContents[_writer].push(contractAddress);

        _transferInitialDeposit(_writer, contractAddress);

        emit RegisterContents(contentsAddress.length.sub(1), contractAddress, _writer, _writerName, _record);
    }

    function getContentsAddress() external view returns (address[] contentsAddress_){
        contentsAddress_ = contentsAddress;
    }

    function getPublishContentsAddress() external view returns (address[] contentsAddress_) {
        uint256 _idx;

        for(uint i = 0 ; i < contentsAddress.length ; i++) {
            if(Content(contentsAddress[i]).getIsBlocked() == false) {
                _idx = _idx.add(1);
            }
        }
        contentsAddress_ = new address[](_idx);

        _idx = 0;
        for(i = 0 ; i < contentsAddress.length ; i++) {
            if(Content(contentsAddress[i]).getIsBlocked() == false) {
                contentsAddress_[_idx] = contentsAddress[i];
                _idx++;
            }
        }
    }

    function getWriterContentsAddress(address _writer)
        external
        view
        returns (address[] writerContentsAddress_)
    {
        writerContentsAddress_ = writerContents[_writer];
    }

    function receiveApproval(address _from, uint256 _value, address _token, bytes _data)
        public
        validAddress(_from) validAddress(_token)
    {
        require(address(token) == _token);
        require(council.getInitialDeposit() == _value);
        require(initialDeposit[_from] == 0);

        CustomToken(address(token)).transferFromPxl(_from, address(this), _value, "작품 등록 예치금 입금");
        initialDeposit[_from] = _value;

        emit ContentInitialDeposit(_from, _value);
    }

    function getInitialDeposit(address _writer)
        external
        view
        returns (uint256 initialDeposit_)
    {
        initialDeposit_ = initialDeposit[_writer];
    }

    function _transferInitialDeposit(address _writer, address _content)
        private
        validAddress(_writer) validAddress(_content)
    {
        uint256 depositAmount = initialDeposit[_writer];
        initialDeposit[_writer] = 0;

        CustomToken(address(token)).approveAndCall(
            council.getDepositPool(),
            depositAmount,
            BytesLib.toBytes(_content));

        emit TransferInitialDeposit(_writer, _content, initialDeposit[_writer]);
    }
}
