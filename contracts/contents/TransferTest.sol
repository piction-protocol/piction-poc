pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/token/ContractReceiver.sol";

contract TransferTest is ContractReceiver {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    ERC20 public token;
    address public dmAddr;

    constructor(address _token, address _dmAddr) public {
        token = ERC20(_token);
        dmAddr = _dmAddr;
    }

    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public {
        require(address(token) == _token);

        token.safeTransferFrom(_from, dmAddr, _value);
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public {
        token.safeTransfer(dmAddr, _value);
    }

}
