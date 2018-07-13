pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/supporter/SponsorshipPool.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/BlockTimeMs.sol";

contract Fundraising is ExtendsOwnable, ContractReceiver, SponsorshipPool {
    using SafeMath for uint256;
    using Math for uint256;
    using SafeERC20 for ERC20;
    using BlockTimeMs for uint256;

    struct Fund {
        uint256 maxcap;
        uint256 softcap;
        uint256 startTime;
        uint256 endTime;
        uint256 distributionRate;
        string image;
        string detail;
    }

    struct Supporter {
        address user;
        uint256 investment;
        uint256 collection;
        uint256 distributionRate;
        bool refund;
    }

    Fund fund;
    uint256 fundRise;
    Supporter[] private pendingSupports;
    ERC20 private pxlToken;

    constructor(
        address _tokenAddress,
        uint256 _maxcap,
        uint256 _softcap,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _distributionRate,
        string _image,
        string _detail)
        public
    {
        require(_softcap <= _maxcap);
        require(!isOnFunding());

        pxlToken = ERC20(_tokenAddress);
        fund = Fund(_maxcap, _softcap, _startTime, _endTime, _distributionRate, _image, _detail);
    }

    function receiveApproval(address _from, uint256 _value, address _token, bytes _data) public {
        support(_from, _value, _token);
    }

    function support(address _from, uint256 _value, address _token) private {
        require(isOnFunding());
        require(address(pxlToken) == _token);
        require(fundRise < fund.maxcap);

        uint256 supportAmount;
        uint256 refundAmount;
        (supportAmount, refundAmount) = getSupportDetail(fund.maxcap, fundRise, _value);

        if(supportAmount > 0) {
            pxlToken.safeTransferFrom(_from, address(this), supportAmount);
        }

        if (refundAmount > 0) {
            pxlToken.safeTransferFrom(_from, _from, refundAmount);
        }

        bool already = false;
        for(uint i = 0; i < pendingSupports.length; i++) {
            if (pendingSupports[i].user == _from) {
                already = true;
                pendingSupports[i].investment = pendingSupports[i].investment.add(supportAmount);
            }
        }

        if (!already) {
            pendingSupports.push(
                Supporter(
                    _from,
                    supportAmount,
                    0,
                    fund.distributionRate,
                    false
                )
            );
        }

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
        require(fund.softcap > fundRise);
        require(fund.endTime <= block.timestamp.getMs());

        uint256 succeed = 0;
        for(uint i = 0; i < pendingSupports.length; i++) {
            if (!pendingSupports[i].refund && succeed < _count)
            {
                require(pxlToken.balanceOf(address(this)) >= pendingSupports[i].investment);

                pendingSupports[i].refund = true;
                pxlToken.safeTransfer(pendingSupports[i].user, pendingSupports[i].investment);
                succeed = succeed.add(1);

                emit refund(pendingSupports[i].user, pendingSupports[i].investment, "refund");
            }
        }
    }

    function getPendingSupports()
        external
        view
        returns (address[], uint256[], bool[])
    {
        require(fund.length > 0);
        address[] memory user = new address[](pendingSupports.length.sub(1));
        uint256[] memory investment = new uint256[](pendingSupports.length.sub(1));
        bool[] memory supportRefund = new bool[](pendingSupports.length.sub(1));

        uint256 pendingSupportsIndex = 0;
        for(uint i = 0; i < pendingSupports.length; i++) {
            user[pendingSupportsIndex] = pendingSupports[i].user;
            investment[pendingSupportsIndex] = pendingSupports[i].investment;
            supportRefund[pendingSupportsIndex] = pendingSupports[i].refund;

            pendingSupportsIndex = pendingSupportsIndex.add(1);
        }
        return (user, investment, supportRefund);
    }

    function isOnFunding() public view returns (bool) {
        if (fund.startTime <= block.timestamp.getMs()
            && fund.endTime >= block.timestamp.getMs())
        {
            if (fundRise < fund.maxcap) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    event Support(address _from, uint256 supportAmount, uint256 refundAmount);
    event refund(address, uint256 investment, string reason);
}
