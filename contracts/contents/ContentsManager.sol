pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/token/CustomToken.sol";
import "contracts/interface/ICouncil.sol";

import "contracts/contents/Content.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/BytesLib.sol";

contract ContentsManager is ContractReceiver, ValidValue {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    mapping (address => uint256) initialDeposit;
    mapping (address => uint256[]) writerContents;

    address[] public contentsAddress;
    ICouncil council;
    ERC20 token;

    constructor(address _councilAddr)
        public
        validAddress(_councilAddr)
    {
        council = ICouncil(_councilAddr);
        token = ERC20(council.getToken());
    }

    function addContents(
        string _record,
        uint256 _marketerRate
    )
        external
        validString(_record)
    {
        require(council.getInitialDeposit() == initialDeposit[msg.sender]);

        address contractAddress = new Content(
            _record, msg.sender, _marketerRate, address(council));

        Content(contractAddress).transferOwnership(msg.sender);

        contentsAddress.push(contractAddress);
        writerContents[msg.sender].push(contentsAddress.length.sub(1));

        transferInitialDeposit(msg.sender, contractAddress);
        initialDeposit[msg.sender] = 0;

        emit RegisterContents(contractAddress, contentsAddress.length);
    }

    function getContents() external view returns (address[]){
        return contentsAddress;
    }

    function getWriterContentsAddress(address _writer)
        external
        view
        returns (address[], bool)
    {
        uint256 length = writerContents[_writer].length;

        if(length == 0) {
            return (new address[](0), false);
        } else {
            address[] memory writerContentsAddress = new address[](length);

            for(uint256 i = 0 ; i < length ; i++) {
                writerContentsAddress[i] = contentsAddress[writerContents[_writer][i]];
            }

            return (writerContentsAddress, true);
        }
    }

    function receiveApproval(address _from, uint256 _value, address _token, bytes _data)
        public
        validAddress(_from) validAddress(_token)
    {
        require(address(token) == _token);
        require(council.getInitialDeposit() == _value);
        require(initialDeposit[_from] == 0);

        token.safeTransferFrom(_from, address(this), _value);
        initialDeposit[_from] = _value;

        emit ContentInitialDeposit(_from, _value);
    }

    function getInitialDeposit(address _writer)
        public
        view
        returns (uint256)
    {
        return initialDeposit[_writer];
    }

    function transferInitialDeposit(address _writer, address _content)
        private
        validAddress(_writer) validAddress(_content)
    {
        require(token.balanceOf(address(this)) >= initialDeposit[_writer]);
        require(council.getDepositPool() != address(0));

        CustomToken(address(token)).approveAndCall(
            council.getDepositPool(),
            initialDeposit[_writer],
            BytesLib.toBytes(_content));

        emit TransferInitialDeposit(_writer, _content, initialDeposit[_writer]);
    }

    event RegisterContents(address _contentAddress, uint256 _registerCount);
    event ContentInitialDeposit(address _writer, uint256 _amount);
    event TransferInitialDeposit(address _writer, address _content, uint256 _value);
}
