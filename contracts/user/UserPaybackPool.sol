pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/council/CouncilInterface.sol";
import "contracts/utils/BlockTimeMs.sol";
import "contracts/utils/ParseLib.sol";
import "contracts/utils/ExtendsOwnable.sol";

/**
 * @title UserPaybackPool contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */

contract UserPaybackPool is ExtendsOwnable, ContractReceiver, ValidValue {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using BlockTimeMs for uint256;
    using ParseLib for string;

    struct PaybackPool {
        uint256 createTime;
        mapping (address => uint256) paybackInfo;
        mapping (address => bool) released;
    }
    PaybackPool[] paybackPool;

    CouncilInterface council;

    uint256 currentIndex;
    uint256 releaseInterval;

    mapping (address => uint256) lastReleaseTime; // 유저별 릴리즈 interval

    constructor(
        address _councilAddress)
        public
        validAddress(_councilAddress)
    {
        council = CouncilInterface(_councilAddress);
        releaseInterval = 10 minutes;//600000; //for test 10min
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
        uint256 createTime = block.timestamp.getMs();

        paybackPool.push(PaybackPool(createTime));

        emit CreatePaybackPool(currentIndex);
    }

    function addPayback(address _from, uint256 _value, address _token, string _user) private {
        ERC20 token = ERC20(council.getToken());
        require(address(token) == _token);

        // 현재 paybackpool 의 생성 시간이 30일 지났으면 새로 생성
        if (block.timestamp.getMs() >= paybackPool[currentIndex].createTime.add(30 days)) {
            createPaybackPool();
        }

        token.safeTransferFrom(_from, address(this), _value);

        address user = _user.parseAddr();
        paybackPool[currentIndex].paybackInfo[user] = paybackPool[currentIndex].paybackInfo[user].add(_value);

        emit AddPayback(user, currentIndex, _value);
    }

    function release() public validAddress(msg.sender) {
        ERC20 token = ERC20(council.getToken());
        require(block.timestamp.getMs() >= lastReleaseTime[msg.sender].add(releaseInterval)); // 릴리즈 주기

        lastReleaseTime[msg.sender] = block.timestamp.getMs();

        for (uint256 i = 0; i < paybackPool.length; i++) {
            if (block.timestamp.getMs() >= paybackPool[i].createTime.add(30 days)) { // 30일 지난것만
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

    event AddPayback(address _user, uint256 _currentIndex, uint256 _value);
    event CreatePaybackPool(uint256 _currentIndex, uint256 _createTime);
    event Release(address _user, uint256 _currentIndex, uint256 _releaseAmount);
}
