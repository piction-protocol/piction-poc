pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/Math.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/supporter/SponsorshipPool.sol";
import "contracts/utils/ExtendsOwnable.sol";

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
        address _writerAddress,
        address _tokenAddress,
        uint256 _numberOfRelease,
        uint256 _maxcap,
        uint256 _softcap,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _distributionRate,
        string _image,
        string _detail)
        SponsorshipPool(_writerAddress, _tokenAddress, _numberOfRelease, _endTime)
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
        view
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

    function getDistributeAmount(uint256 _total, uint256 _remainder) external returns(address, uint256) {
        //todo
        return (new address[](0), new uint256[](0));
    }

    event Support(address _from, uint256 supportAmount, uint256 refundAmount);
    event Refund(address, uint256 investment, string reason);
}
