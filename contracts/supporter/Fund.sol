pragma solidity ^0.4.24;

import "contracts/supporter/SponsorshipPool.sol";
import "contracts/council/CouncilInterface.sol";
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

    struct Supporter {
        address user;
        uint256 investment;
        uint256 collection;
        uint256 distributionRate;
    }

    uint256 startTime;
    uint256 endTime;
    string detail;

    address council;
    address content;
    address writer;

    uint256 fundRise;
    Supporter[] supporters;
    uint256 poolSize;
    uint256 releaseInterval;
    uint256 distributionRate;

    SponsorshipPool public sponsorshipPool;

    constructor(
        address _council,
        address _content,
        address _writer,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _poolSize,
        uint256 _releaseInterval,
        uint256 _distributionRate,
        string _detail)
    public validAddress(_content) validAddress(_writer) validAddress(_council) {
        require(_startTime > TimeLib.currentTime());
        require(_endTime > _startTime);
        require(_poolSize > 0);
        require(_releaseInterval > 0);
        require(distributionRate <= 100);

        council = _council;
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
        require(TimeLib.currentTime().between(startTime, endTime));

        ERC20 token = ERC20(CouncilInterface(council).getToken());
        require(address(token) == _token);

        uint256 index;
        bool success;
        (index, success) = findSupporterIndex(_from);
        if (success) {
            supporters[index].investment = supporters[index].investment.add(_value);
        } else {
            supporters.push(Supporter(_from, _value, 0, 0));
        }
        fundRise = fundRise.add(_value);
        token.safeTransferFrom(_from, address(this), _value);

        emit Support(_from, _value);
    }

    function startDistribution() external {
        require(address(sponsorshipPool) == address(0));
        require(TimeLib.currentTime() < endTime);
        require(fundRise > 0);

        setDistributionRate();
        sponsorshipPool = new SponsorshipPool(fundRise, poolSize, releaseInterval);
    }

    function setDistributionRate() private {
        uint256 totalInvestment;
        for (uint256 i = 0; i < supporters.length; i++) {
            totalInvestment = totalInvestment.add(supporters[i].investment);
        }
        for (i = 0; i < supporters.length; i++) {
            supporters[i].distributionRate = totalInvestment.div(supporters[i].investment);
        }
    }

    function releasePool() external validAddress(sponsorshipPool) {
        uint256 amount = sponsorshipPool.release();
        ERC20 token = ERC20(CouncilInterface(council).getToken());
        token.safeTransfer(writer, amount);
    }

    function vote() external validAddress(sponsorshipPool) {
        require(isSupporter(msg.sender));

        sponsorshipPool.vote(msg.sender);
        address[] memory _supporters = new address[](supporters.length);
        (_supporters,) = getSupporters();
        uint256 votingCount = sponsorshipPool.getVotingCount(_supporters);
        if (supporters.length.div(2) <= votingCount) {
            uint256 cancelAmount = sponsorshipPool.cancelPool();
            sponsorshipPool.addPool(cancelAmount);
        }
    }

    function distribution(uint256 _total) external returns (address[], uint256[]) {
        address[] memory _supporters = new address[](supporters.length);
        uint256[] memory _amounts = new uint256[](supporters.length);

        for (uint256 i = 0; i < supporters.length; i++) {
            _supporters[i] = supporters[i].user;
            uint256 remain = supporters[i].investment.sub(supporters[i].collection);
            if (remain == 0) {
                _amounts[i] = _total.div(distributionRate).div(supporters[i].distributionRate);
            } else {
                _amounts[i] = _total.div(supporters[i].distributionRate).min256(remain);
                supporters[i].collection = supporters[i].collection.add(_amounts[i]);
            }
        }
        return (_supporters, _amounts);
    }

    function getSupporters() public view returns (address[], uint256[]) {
        address[] memory user = new address[](supporters.length - 1);
        uint256[] memory investment = new uint256[](supporters.length - 1);

        uint256 supportersIndex = 0;
        for (uint256 i = 0; i < supporters.length; i++) {
            user[supportersIndex] = supporters[i].user;
            investment[supportersIndex] = supporters[i].investment;

            supportersIndex = supportersIndex.add(1);
        }
        return (user, investment);
    }

    function getSupportCount() public view returns (uint256) {
        return supporters.length;
    }

    function getDistributionRate() public view returns (uint256){
        return distributionRate;
    }

    function findSupporterIndex(address _supporter) private view returns (uint, bool){
        for (uint256 i = 0; i < supporters.length; i++) {
            if (supporters[i].user == _supporter) {
                return (i, true);
            }
        }
    }

    function isSupporter(address _supporter) private view returns (bool){
        for (uint256 i = 0; i < supporters.length; i++) {
            if (supporters[i].user == _supporter) {
                return true;
            }
        }
    }

    event Support(address _from, uint256 _amount);
}