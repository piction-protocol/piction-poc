pragma solidity ^0.4.24;

import "contracts/council/Council.sol";
import "contracts/supporter/FundData.sol";
import "contracts/token/ContractReceiver.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Fund is ContractReceiver, ExtendsOwnable, ValidValue {
    using Math for uint256;
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using TimeLib for *;

    uint256 startTime;
    uint256 endTime;
    string detail;

    address content;
    address writer;
    address council;

    uint256 fundRise;
    FundData.Supporter[] supporters;
    FundData.Pool[] pools;
    uint256 poolSize;
    uint256 releaseInterval;
    uint256 distributionRate;

    constructor(
        address _content,
        address _writer,
        address _council,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _poolSize,
        uint256 _releaseInterval,
        uint256 _distributionRate,
        string _detail)
    public validAddress(_content) validAddress(_writer) validAddress(_council) {
        require(_startTime > TimeLib.currentTime());

        startTime = _startTime;
        endTime = _endTime;
        detail = _detail;
        poolSize = _poolSize;
        releaseInterval = _releaseInterval;
        distributionRate = _distributionRate;
    }

    function receiveApproval(address _from, uint256 _value, address _token, string _data) public validAddress(_from) validAddress(_token) {
        support(_from, _value, _token);
    }

    function support(address _from, uint256 _value, address _token) private {
        require(isOnFunding());

        ERC20 token = ERC20(Council(council).token());
        require(address(token) == _token);

        FundData.Supporter memory supporter = findSupporter(_from);
        if (supporter.user == 0) {
            supporters.push(FundData.Supporter(_from, _value, 0));
        } else {
            supporter.investment = supporter.investment.add(_value);
        }
        fundRise = fundRise.add(_value);

        emit Support(_from, _value);
    }

    function findSupporter(address _supporter) private view returns (FundData.Supporter){
        FundData.Supporter memory supporter;
        for (uint i = 0; i < supporters.length; i++) {
            if (supporters[i].user == _supporter) {
                supporter = supporters[i];
                break;
            }
        }
        return supporter;
    }

    function isOnFunding() public view returns (bool) {
        return TimeLib.currentTime().between(startTime, endTime);
    }

    event Support(address _from, uint256 _amount);

    function createPool(uint _poolSize, uint _amount, uint _intervalTime) private {
        uint firstDistributionTime = TimeLib.currentTime().add(_intervalTime);
        uint poolAmount = _amount.div(_poolSize);
        for (uint i = 0; i < _poolSize; i++) {
            addPool(poolAmount, firstDistributionTime.add(i.mul(_intervalTime)));
        }
        uint remainder = _amount.sub(poolAmount.mul(_poolSize));
        if (remainder > 0) {
            pools[pools.length - 1].amount = pools[pools.length - 1].amount.add(remainder);
        }
    }

    function addPool(uint _amount, uint distributionTime) private {
        FundData.Pool memory pool = FundData.Pool(_amount, distributionTime, 0, FundData.PoolState.PENDING);
        pools.push(pool);
    }

    function release() external {
        uint amount;
        for (uint i = 0; i < pools.length; i++) {
            FundData.Pool memory pool = pools[i];
            if (pool.distributionTime < TimeLib.currentTime() && pool.state == FundData.PoolState.PENDING) {
                pool.distributedTime = TimeLib.currentTime();
                pool.state = FundData.PoolState.PAID;
                amount.add(pool.amount);

                emit Release(pool.amount);
            }
        }
        ERC20 token = ERC20(Council(council).token());
        token.safeTransfer(writer, amount);
    }

    function vote(uint poolIndex) external returns (bool) {
        FundData.Pool storage pool = pools[poolIndex];
        pool.voting[msg.sender] = true;

        uint votingCount;
        for (uint256 i = 0; i < supporters.length; i++) {
            votingCount.add(isVoting(pool, supporters[i]));
        }

        if (supporters.length.div(2) <= votingCount) {
            pool.state = FundData.PoolState.CANCEL_PAYMENT;
            uint distributionTime = pools[pools.length - 1].distributionTime.add(releaseInterval);
            pools.push(FundData.Pool(pool.amount, distributionTime, 0, FundData.PoolState.PENDING));
        }
    }

    function isVoting(FundData.Pool storage _pool, FundData.Supporter storage _supporter) private view returns (uint){
        return _pool.voting[_supporter.user] ? 1 : 0;
    }

    function getTotalInvestment() public view returns (uint256) {
        uint256 total;
        for (uint256 i = 0; i < supporters.length; i++) {
            total = total.add(supporters[i].investment);
        }
        return total;
    }

    function getTotalCollection() public view returns (uint256) {
        uint256 total;
        for (uint256 i = 0; i < supporters.length; i++) {
            total = total.add(supporters[i].collection);
        }
        return total;
    }

    function getDistributeAmount(uint256 _total) external view returns (address[], uint256[]) {
        require(msg.sender == content);

        address[] memory _supporters = new address[](supporters.length);
        uint256[] memory _amounts = new uint256[](supporters.length);

        uint256 totalInvestment = getTotalInvestment();
        uint256 totalRemain = totalInvestment.sub(getTotalCollection());
        uint256 distributeAmount = (totalRemain == 0) ? _total.div(distributionRate) : _total;
        for (uint256 i = 0; i < supporters.length; i++) {
            _supporters[i] = supporters[i].user;
            uint256 rate = totalInvestment.div(supporters[i].investment);
            uint256 rateAmount = distributeAmount.div(rate);
            uint256 remainAmount = supporters[i].investment.sub(supporters[i].collection);
            _amounts[i] = rateAmount.min256(remainAmount);
        }

        return (_supporters, _amounts);
    }

    function getSupporters() external view returns (address[], uint256[]) {
        address[] memory user = new address[](supporters.length.sub(1));
        uint256[] memory investment = new uint256[](supporters.length.sub(1));

        uint256 supportersIndex = 0;
        for (uint i = 0; i < supporters.length; i++) {
            user[supportersIndex] = supporters[i].user;
            investment[supportersIndex] = supporters[i].investment;

            supportersIndex = supportersIndex.add(1);
        }
        return (user, investment);
    }

    function getSupportersLength() external view returns (uint256) {
        return supporters.length;
    }

    function getDistributionRate() external view returns (uint256){
        return distributionRate;
    }

    event Voting(address user, bool interrupt);
    event Release(uint amount);
}