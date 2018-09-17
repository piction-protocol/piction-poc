pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/interface/IContractReceiver.sol";
import "contracts/interface/ICouncil.sol";

import "contracts/access/RoleManager.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/BytesLib.sol";


/**
 * @title UserPaybackPool contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */

contract UserPaybackPool is ExtendsOwnable, IContractReceiver, ValidValue {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using TimeLib for *;
    using BytesLib for bytes;

    string public constant ROLE_NAME = "PXL_DISTRIBUTOR";

    struct PaybackPool {
        uint256 createTime;
        mapping (address => uint256) paybackInfo;
        mapping (address => bool) released;
    }
    PaybackPool[] paybackPool;

    ICouncil council;

    uint256 currentIndex;
    uint256 releaseInterval;
    uint256 createPoolInterval;

    mapping (address => uint256) lastReleaseTime; // 유저별 릴리즈 interval

    constructor(
        address _councilAddress,
        uint256 _createPoolInterval)
        public
        validAddress(_councilAddress)
        validRange(_createPoolInterval)
    {
        council = ICouncil(_councilAddress);
        createPoolInterval = _createPoolInterval * 1 seconds;
        releaseInterval = 10 minutes;//600000; //for test 10min
    }

    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes _data)
        public
        validAddress(_from)
        validAddress(_token)
    {
        addPayback(_from, _value, _token, _data);
    }

    function createPaybackPool() private {
        if (paybackPool.length > 0) { // paybackpool이 없으면 currentIndex 0으로 유지
            currentIndex = currentIndex.add(1);
        }
        uint256 createTime = TimeLib.currentTime();

        paybackPool.push(PaybackPool(createTime));

        emit CreatePaybackPool(currentIndex);
    }

    function addPayback(address _from, uint256 _value, address _token, bytes _data) private {
        require(RoleManager(council.getRoleManager()).isAccess(_from, ROLE_NAME));

        ERC20 token = ERC20(council.getToken());
        require(address(token) == _token);

        // 현재 paybackpool 의 생성 시간이 createPoolInterval만큼 지났으면 새로 생성
        if (paybackPool.length == 0 || TimeLib.currentTime() >= paybackPool[currentIndex].createTime.add(createPoolInterval)) {
            createPaybackPool();
        }

        token.safeTransferFrom(_from, address(this), _value);

        address user = _data.toAddress(0);
        paybackPool[currentIndex].paybackInfo[user] = paybackPool[currentIndex].paybackInfo[user].add(_value);

        emit AddPayback(user, currentIndex, _value);
    }

    function release() public {
        ERC20 token = ERC20(council.getToken());
        require(TimeLib.currentTime() >= lastReleaseTime[msg.sender].add(releaseInterval)); // 릴리즈 주기

        lastReleaseTime[msg.sender] = TimeLib.currentTime();

        for (uint256 i = 0; i < paybackPool.length; i++) {
            if (TimeLib.currentTime() >= paybackPool[i].createTime.add(createPoolInterval)) { // createPoolInterval만큼 지난것만
                bool released = paybackPool[i].released[msg.sender];
                if (!released) {
                    uint256 paybackAmount = paybackPool[i].paybackInfo[msg.sender];
                    paybackPool[i].released[msg.sender] = true;

                    token.safeTransfer(msg.sender, paybackAmount);

                    emit Release(msg.sender, i, paybackAmount);
                }
            }
        }
    }

    function getCurrentIndex() public view returns(uint256) {
        return currentIndex;
    }

    function getPaybackInfo() public view returns(uint256[], uint256[], uint256[], uint256[], bool[]) {
        uint256[] memory poolIndex = new uint256[](paybackPool.length);
        uint256[] memory paybackAmount = new uint256[](paybackPool.length);
        uint256[] memory createdTime = new uint256[](paybackPool.length);
        uint256[] memory distributableTime = new uint256[](paybackPool.length);
        bool[] memory released = new bool[](paybackPool.length);

        for (uint256 i = 0; i < paybackPool.length; i++) {
            poolIndex[i] = i;
            paybackAmount[i] = paybackPool[i].paybackInfo[msg.sender];
            createdTime[i] = paybackPool[i].createTime;
            distributableTime[i] = paybackPool[i].createTime.add(createPoolInterval);
            released[i] = paybackPool[i].released[msg.sender];
        }

        return (poolIndex, paybackAmount, createdTime, distributableTime, released);
    }

    event AddPayback(address _user, uint256 _currentIndex, uint256 _value);
    event CreatePaybackPool(uint256 _currentIndex);
    event Release(address _user, uint256 _currentIndex, uint256 _releaseAmount);
}
