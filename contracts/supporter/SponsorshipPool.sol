pragma solidity ^0.4.24;

import "contracts/council/Council.sol";
import "contracts/utils/TimeLib.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract SponsorshipPool is Ownable {
    using Math for uint256;
    using SafeMath for uint256;
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
    uint interval;

    constructor(
        uint256 _amount,
        uint256 _size,
        uint256 _interval)
    public {
        interval = _interval;
        createPool(_amount, _size);
    }

    function createPool(uint _amount, uint _size) private {
        uint poolAmount = _amount.div(_size);
        for (uint i = 0; i < _size; i++) {
            addPool(poolAmount);
        }
        uint remainder = _amount.sub(poolAmount.mul(_size));
        if (remainder > 0) {
            pools[pools.length - 1].amount = pools[pools.length - 1].amount.add(remainder);
        }
    }

    function getCurrentIndex() private view returns (uint, bool){
        for (uint i = 0; i < pools.length; i++) {
            uint startTime = pools[i].distributionTime;
            uint endTime = pools[i].distributionTime.sub(interval);
            if (TimeLib.currentTime().between(startTime, endTime)) {
                return (i, true);
            }
        }
    }

    function addPool(uint _amount) public onlyOwner {
        uint distributionTime;
        if (pools.length == 0) {
            distributionTime = TimeLib.currentTime().add(interval);
        } else {
            distributionTime = pools[pools.length - 1].distributionTime.add(interval);
        }
        pools.push(Pool(_amount, distributionTime, 0, PoolState.PENDING));
    }

    function cancelPool() external onlyOwner returns (uint){
        uint index;
        bool success;
        (index, success) = getCurrentIndex();
        if (success) {
            pools[index].state = PoolState.CANCEL_PAYMENT;
            return pools[index].amount;
        }
    }

    function release() external onlyOwner returns (uint _amount){
        for (uint i = 0; i < pools.length; i++) {
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
        uint index;
        bool success;
        (index, success) = getCurrentIndex();
        if (success) {
            pools[index].voting[_user] = true;
        }
    }

    function getVotingCount(address[] _users) public view returns (uint _count) {
        uint index;
        bool success;
        (index, success) = getCurrentIndex();
        if (success) {
            for (uint i = 0; i < _users.length; i++) {
                _count.add(isVoting(index, _users[i]));
            }
        }
    }

    function isVoting(uint poolIndex, address _user) private view returns (uint){
        return pools[poolIndex].voting[_user] ? 1 : 0;
    }

    event Voting(address user, bool interrupt);
    event Release(uint amount);
}