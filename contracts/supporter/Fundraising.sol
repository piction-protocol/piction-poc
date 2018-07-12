pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/token/CustomToken.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/BlockTimeMs.sol";

contract Fundraising is ExtendsOwnable, ContractReceiver {
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
        bool release;
    }

    Fund[] private funds;
    uint256[] private fundRise;
    Supporter[] private pendingSupports;
    ERC20 private pxlToken;

    constructor(address _tokenAddress) public {
        pxlToken = ERC20(_tokenAddress);
    }

    function addFund(
        uint256 _maxcap,
        uint256 _softcap,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _distributionRate,
        string _image,
        string _detail)
        external
    {
        require(_softcap <= _maxcap);
        require(!isOnFunding());

        funds.push(Fund(_maxcap, _softcap, _startTime, _endTime, _distributionRate, _image, _detail));
        fundRise.push(0);
        delete pendingSupports;

        emit AddFund(_maxcap, _softcap, _startTime, _endTime, _distributionRate, _image, _detail);
    }

    function receiveApproval(address _from, uint256 _value, address _token, bytes _data) public {
        support(_from, _value, _token);
    }

    function support(address _from, uint256 _value, address _token) private {
        require(isOnFunding());
        require(address(pxlToken) == _token);
        require(fundRise[fundRise.length.sub(1)] < funds[funds.length.sub(1)].maxcap);

        uint256 supportAmount;
        uint256 refundAmount;
        (supportAmount, refundAmount) = getSupportDetail(
            funds[funds.length.sub(1)].maxcap,
            fundRise[fundRise.length.sub(1)],
            _value);

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
                    funds[funds.length.sub(1)].distributionRate,
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

    function release(uint256 _count) external {
        require(funds.length > 0);
        require(funds[funds.length.sub(1)].endTime <= block.timestamp.getMs());

        uint256 succeed = 0;
        for(uint i = 0; i < pendingSupports.length; i++) {
            if (!pendingSupports[i].release && succeed < _count) {
                require(pxlToken.balanceOf(address(this)) >= pendingSupports[i].investment);
                pendingSupports[i].release = true;

                if (funds[funds.length.sub(1)].softcap <= fundRise[funds.length.sub(1)]) {
                    //send Pool
                    CustomToken cToken = CustomToken(address(pxlToken));
                    //cToken.approveAndCall(pool Address, amount, data);
                    //data ... data ...

                    emit Release(pendingSupports[i].user, pendingSupports[i].investment, "sendToPool");
                } else {
                    pxlToken.safeTransfer(pendingSupports[i].user, pendingSupports[i].investment);

                    emit Release(pendingSupports[i].user, pendingSupports[i].investment, "refund");
                }
                succeed = succeed.add(1);
            }
        }
    }

    function getPendingSupports()
        external
        view
        returns (address[], uint256[], bool[])
    {
        require(funds.length > 0);
        address[] memory user = new address[](pendingSupports.length.sub(1));
        uint256[] memory investment = new uint256[](pendingSupports.length.sub(1));
        bool[] memory supportRelease = new bool[](pendingSupports.length.sub(1));

        uint256 pendingSupportsIndex = 0;
        for(uint i = 0; i < pendingSupports.length; i++) {
            user[pendingSupportsIndex] = pendingSupports[i].user;
            investment[pendingSupportsIndex] = pendingSupports[i].investment;
            supportRelease[pendingSupportsIndex] = pendingSupports[i].release;

            pendingSupportsIndex = pendingSupportsIndex.add(1);
        }
        return (user, investment, supportRelease);
    }

    function isOnFunding() public view returns (bool) {
        if (funds.length == 0) {
            return false;
        }

        if (funds[funds.length.sub(1)].startTime <= block.timestamp.getMs()
            && funds[funds.length.sub(1)].endTime >= block.timestamp.getMs())
        {
            if (fundRise[fundRise.length.sub(1)] < funds[funds.length.sub(1)].maxcap) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    event AddFund(
        uint256 maxcap,
        uint256 softcap,
        uint256 startTime,
        uint256 endTime,
        uint256 distributionRate,
        string image,
        string detail);
    event Support(address _from, uint256 supportAmount, uint256 refundAmount);
    event Release(address, uint256 investment, string reason);
}
