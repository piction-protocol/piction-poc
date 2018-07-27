pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/council/Council.sol";
import "contracts/utils/BlockTimeMs.sol";
import "contracts/utils/ParseLib.sol";

/**
 * @title UserPaybackPool contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */

contract UserPaybackPool is ContractReceiver, ValidValue {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using BlockTimeMs for uint256;
    using ParseLib for string;

    struct PaybackPool {
        address[] user;
        uint256 releaseTime;
        uint256 totalReleaseAmount;
        mapping (address => uint256) paybackInfo;
        mapping (address => bool) released;
    }

    uint256 currentIndex;
    address councilAddress;
    PaybackPool[] paybackPool;
    uint256 releaseInterval;
    uint256 lastReleaseTime;

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
        addPayback(_from, _value, _token, _data);
    }

    function createPaybackPool() private {
        currentIndex = currentIndex.add(1);
        paybackPool.push(PaybackPool(new address[](0), 0, 0));

        uint256 createTime = block.timestamp.getMs();

        emit AddPaybackPool(currentIndex, createTime);
    }

    function addPayback(address _from, uint256 _value, address _token, string _user) private {
        ERC20 token = ERC20(Council(councilAddress).token());
        require(address(token) == _token);

        address user = _user.parseAddr();

        token.safeTransferFrom(_from, address(this), _value);

        if (paybackPool[currentIndex].paybackInfo[user] == 0) {
            paybackPool[currentIndex].paybackInfo[user] = _value;
            paybackPool[currentIndex].released[user] = false;
            paybackPool[currentIndex].user.push(user);
        } else {
            paybackPool[currentIndex].paybackInfo[user] = paybackPool[currentIndex].paybackInfo[user].add(_value);
        }
        paybackPool[currentIndex].totalReleaseAmount = paybackPool[currentIndex].totalReleaseAmount.add(_value);
        uint256 paymentTime = block.timestamp.getMs();

        emit AddPayback(user, _value, paymentTime);
    }

    function releaseMonthly() external {
        require(block.timestamp.getMs() >= lastReleaseTime.add(releaseInterval));
        ERC20 token = ERC20(Council(councilAddress).token());
        require(token.balanceOf(address(this)) >= paybackPool[currentIndex].totalReleaseAmount);

        uint256 totalReleaseAmount = paybackPool[currentIndex].totalReleaseAmount;

        for(uint i = 0; i < paybackPool[currentIndex].user.length; i++) {
            address user = paybackPool[currentIndex].user[i];
            bool released = paybackPool[currentIndex].released[user];
            uint256 paybackAmount = paybackPool[currentIndex].paybackInfo[user];

            if (!released) {
              token.safeTransfer(user, paybackAmount);
            }
        }

        uint256 releaseTime = block.timestamp.getMs();
        paybackPool[currentIndex].releaseTime = releaseTime;
        lastReleaseTime = releaseTime;

        createPaybackPool();

        emit ReleaseMonthly(releaseTime, totalReleaseAmount);
    }

    function getCurrentIndex() public view returns(uint256) {
        return currentIndex;
    }

    function getPaybackInfo(address _user) public validAddress(_user) view returns(uint256, bool) {
        uint256 paybackAmount = paybackPool[currentIndex].paybackInfo[_user];
        bool released = paybackPool[currentIndex].released[_user];

        return (paybackAmount, released);
    }

    event AddPayback(address _user, uint256 _value, uint256 _lastPaymentTime);
    event AddPaybackPool(uint256 _currentIndex, uint256 _createTime);
    event ReleaseMonthly(uint256 _releaseTime, uint256 _releaseAmount);
}
