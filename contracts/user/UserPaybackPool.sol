pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/council/Council.sol";
import "contracts/utils/BlockTimeMs.sol";

/**
 * @title UserPaybackPool contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */

contract UserPaybackPool is ContractReceiver, ValidValue {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using Math for uint256;
    using BlockTimeMs for uint256;

    struct PaybackInfo {
        address user;
        uint256 paybackAmount;
        uint256 lastPaymentTime;
        bool released;
    }

    address councilAddress;
    PaybackInfo[] paybackInfo;
    uint256 lastReleaseTime;
    uint256 releaseInterval;
    uint256 releaseAmount;

    constructor(
        address _councilAddress)
        public
    {
        councilAddress = _councilAddress;
        releaseInterval = 600000; //for test 10min
    }

    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        string _data)
        public
        validAddress(_from)
        validAddress(_token)
    {
        addPayback(_from, _value, _token);
    }

    function addPayback(address _from, uint256 _value, address _token) private {
        ERC20 token = ERC20(Council(councilAddress).token());
        require(address(token) == _token);

        uint256 paymentTime = block.timestamp.getMs();

        token.safeTransferFrom(_from, address(this), _value);

        bool already = false;
        for(uint i = 0; i < paybackInfo.length; i++) {
            if (paybackInfo[i].user == _from && lastReleaseTime <= paymentTime) {
                already = true;
                paybackInfo[i].paybackAmount = paybackInfo[i].paybackAmount.add(_value);
            }
        }

        if (!already) {
            paybackInfo.push(PaybackInfo(_from, _value, paymentTime, false));
        }

        emit AddPayback(_from, _value, paymentTime);
    }

    function releaseMonthly() external {
        require(block.timestamp.getMs() >= lastReleaseTime.add(releaseInterval));
        ERC20 token = ERC20(Council(councilAddress).token());
        require(token.balanceOf(address(this)) >= releaseAmount);

        uint256 releaseTime = block.timestamp.getMs();

        for(uint i = 0; i < paybackInfo.length; i++) {
            if (paybackInfo[i].lastPaymentTime <= releaseTime && !paybackInfo[i].released) {
                token.safeTransfer(paybackInfo[i].user, paybackInfo[i].paybackAmount);
                paybackInfo[i].released = true;
            }
        }

        uint256 deleteIndex = 0;
        for(uint j = 0; deleteIndex < paybackInfo.length - 1; j++) {
            if (paybackInfo[j].released) {
                paybackInfo[j] = paybackInfo[j+1];
                deleteIndex = deleteIndex.add(1);
            }
        }
        delete paybackInfo[paybackInfo.length - deleteIndex];
        paybackInfo.length = paybackInfo.length.sub(deleteIndex);

        lastReleaseTime = releaseTime;

        emit ReleaseMonthly(releaseTime, releaseAmount);
    }

    event AddPayback(address _from, uint256 _value, uint256 _lastPaymentTime);
    event ReleaseMonthly(uint256 _releaseTime, uint256 _releaseAmount);
}
