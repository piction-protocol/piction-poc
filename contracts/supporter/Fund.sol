pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/supporter/SponsorshipPool.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/BlockTimeMs.sol";

contract Fund is ExtendsOwnable, ContractReceiver, SponsorshipPool {
    using SafeMath for uint256;
    using Math for uint256;
    using SafeERC20 for ERC20;
    using BlockTimeMs for uint256;

    uint256 maxcap;
    uint256 softcap;
    uint256 startTime;
    uint256 endTime;
    uint256 distributionRate;
    string image;
    string detail;

    constructor(
        address _tokenAddress,
        uint256 _stripPeriod,
        uint256 _maxcap,
        uint256 _softcap,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _distributionRate,
        string _image,
        string _detail)
        SponsorshipPool(_tokenAddress, _stripPeriod)
        public
    {
        require(_softcap <= _maxcap);
        require(_startTime > block.timestamp.getMs());

        maxcap = _maxcap;
        softcap = _softcap;
        startTime = _startTime;
        endTime = _endTime;
        distributionRate = _distributionRate;
        image = _image;
        detail = _detail;
    }

    function receiveApproval(address _from, uint256 _value, address _token, bytes _data) public {
        support(_from, _value, _token);
    }

    function support(address _from, uint256 _value, address _token) private {
        require(isOnFunding());
        require(address(pxlToken) == _token);
        require(fundRise < maxcap);

        uint256 supportAmount;
        uint256 refundAmount;
        (supportAmount, refundAmount) = getSupportDetail(maxcap, fundRise, _value);

        if(supportAmount > 0) {
            pxlToken.safeTransferFrom(_from, address(this), supportAmount);
        }

        if (refundAmount > 0) {
            pxlToken.safeTransferFrom(_from, _from, refundAmount);
        }

        bool already = false;
        for(uint i = 0; i < supports.length; i++) {
            if (supports[i].user == _from) {
                already = true;
                supports[i].investment = supports[i].investment.add(supportAmount);
            }
        }

        if (!already) {
            supports.push(Supporter(_from, supportAmount, 0, false));
        }

        fundRise = fundRise.add(supportAmount);

        emit Support(_from, supportAmount, refundAmount);
    }

    function getSupportDetail(uint256 _maxcap, uint256 _raisedAmount, uint256 _amount)
        private
        pure
        returns (uint256, uint256)
    {
        uint256 d1 = _maxcap.sub(_raisedAmount);
        uint256 possibleAmount = d1.min256(_amount);

        return (possibleAmount, _amount.sub(possibleAmount));
    }

    function refund(uint256 _count) external {
        require(softcap > fundRise);
        require(endTime <= block.timestamp.getMs());

        uint256 succeed = 0;
        for(uint i = 0; i < supports.length; i++) {
            if (!supports[i].refund && succeed < _count)
            {
                require(fundRise >= supports[i].investment);

                supports[i].refund = true;
                pxlToken.safeTransfer(supports[i].user, supports[i].investment);
                succeed = succeed.add(1);

                emit Refund(supports[i].user, supports[i].investment, "refund");
            }
        }
    }

    function getSupports()
        external
        view
        returns (address[], uint256[], bool[])
    {
        address[] memory user = new address[](supports.length.sub(1));
        uint256[] memory investment = new uint256[](supports.length.sub(1));
        bool[] memory supportRefund = new bool[](supports.length.sub(1));

        uint256 supportsIndex = 0;
        for(uint i = 0; i < supports.length; i++) {
            user[supportsIndex] = supports[i].user;
            investment[supportsIndex] = supports[i].investment;
            supportRefund[supportsIndex] = supports[i].refund;

            supportsIndex = supportsIndex.add(1);
        }
        return (user, investment, supportRefund);
    }

    function isOnFunding() public view returns (bool) {
        if (startTime <= block.timestamp.getMs()
            && endTime >= block.timestamp.getMs())
        {
            if (fundRise < maxcap) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    event Support(address _from, uint256 supportAmount, uint256 refundAmount);
    event Refund(address, uint256 investment, string reason);
}
