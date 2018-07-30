pragma solidity ^0.4.24;

import "contracts/council/Council.sol";
import "contracts/utils/TimeLib.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract SponsorshipPool is Ownable {
    using Math for uint256;
    using TimeLib for *;

    enum PoolState {PENDING, PAID, CANCEL_PAYMENT}

    struct Pool {
        uint256 amount;
        uint256 distributionTime;
        uint256 distributedTime;
        PoolState state;
        mapping(address => bool) voting;
    }

    Pool[] pools;
    uint256 interval;

    constructor(
        uint256 _amount,
        uint256 _size,
        uint256 _interval)
    public {
        interval = _interval;
        createPool(_amount, _size);
    }

    function createPool(uint256 _amount, uint256 _size) private {
        uint256 poolAmount = _amount.div(_size);
        for (uint256 i = 0; i < _size; i++) {
            addPool(poolAmount);
        }
        uint256 remainder = _amount.sub(poolAmount.mul(_size));
        if (remainder > 0) {
            pools[pools.length - 1].amount = pools[pools.length - 1].amount.add(remainder);
        }
    }

    function getCurrentIndex() private view returns (uint, bool){
        for (uint256 i = 0; i < pools.length; i++) {
            uint256 startTime = pools[i].distributionTime;
            uint256 endTime = pools[i].distributionTime.sub(interval);
            if (TimeLib.currentTime().between(startTime, endTime)) {
                return (i, true);
            }
        }
    }

    function addPool(uint256 _amount) public onlyOwner {
        uint256 distributionTime;
        if (pools.length == 0) {
            distributionTime = TimeLib.currentTime().add(interval);
        } else {
            distributionTime = pools[pools.length - 1].distributionTime.add(interval);
        }
        pools.push(Pool(_amount, distributionTime, 0, PoolState.PENDING));
    }

    function cancelPool() external onlyOwner returns (uint){
        uint256 index;
        bool success;
        (index, success) = getCurrentIndex();
        if (success) {
            pools[index].state = PoolState.CANCEL_PAYMENT;
            return pools[index].amount;
        }
    }

    function release() external onlyOwner returns (uint256 _amount){
        for (uint256 i = 0; i < pools.length; i++) {
            Pool memory pool = pools[i];
            if (pool.distributionTime < TimeLib.currentTime() && pool.state == PoolState.PENDING) {
                pool.distributedTime = TimeLib.currentTime();
                pool.state = PoolState.PAID;
                _amount.add(pool.amount);

                emit Release(pool.amount);
            }
        }
    }

    function vote(address _user) external onlyOwner {
        uint256 index;
        bool success;
        (index, success) = getCurrentIndex();
        if (success) {
            pools[index].voting[_user] = true;
        }
    }

    function getVotingCount(address[] _users) public view returns (uint256 _count) {
        uint256 index;
        bool success;
        (index, success) = getCurrentIndex();
        if (success) {
            for (uint256 i = 0; i < _users.length; i++) {
                _count.add(isVoting(index, _users[i]));
            }
        }
    }

    function isVoting(uint256 poolIndex, address _user) private view returns (uint){
        return pools[poolIndex].voting[_user] ? 1 : 0;
    }

    event Voting(address user, bool interrupt);
    event Release(uint256 amount);
}