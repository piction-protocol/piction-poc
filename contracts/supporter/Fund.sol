pragma solidity ^0.4.24;

import "contracts/token/ContractReceiver.sol";
import "contracts/supporter/SponsorshipPool.sol";
import "contracts/utils/ExtendsOwnable.sol";

contract Fund is ExtendsOwnable, ContractReceiver, SponsorshipPool {
    using SafeMath for uint256;
    using Math for uint256;
    using SafeERC20 for ERC20;
    using BlockTimeMs for uint256;

    modifier validAddress(address _account) {
        require(_account != address(0));
        require(_account != address(this));
        _;
    }

    uint256 maxcap;
    uint256 softcap;
    uint256 startTime;
    uint256 endTime;
    string image;
    string detail;
    address content;

    constructor(
        address _contentAddress,
        address _writerAddress,
        address _councilAddress,
        uint256 _numberOfRelease,
        uint256 _maxcap,
        uint256 _softcap,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _distributionRate,
        string _image,
        string _detail)
        SponsorshipPool(
            _contentAddress,
            _writerAddress,
            _councilAddress,
            _numberOfRelease,
            _endTime,
            _distributionRate)
        public
        validAddress(_contentAddress)
        validAddress(_writerAddress)
        validAddress(_councilAddress)
    {
        require(_softcap <= _maxcap);
        require(_startTime > block.timestamp.getMs());

        maxcap = _maxcap;
        softcap = _softcap;
        startTime = _startTime;
        endTime = _endTime;
        image = _image;
        detail = _detail;
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
        support(_from, _value, _token);
    }

    function support(address _from, uint256 _value, address _token) private {
        require(isOnFunding());
        ERC20 token = ERC20(Council(councilAddress).token());
        require(address(token) == _token);
        require(fundRise < maxcap);

        uint256 supportAmount;
        uint256 refundAmount;
        (supportAmount, refundAmount) = getSupportDetail(maxcap, fundRise, _value);

        if(supportAmount > 0) {
            token.safeTransferFrom(_from, address(this), supportAmount);
        }

        if (refundAmount > 0) {
            token.safeTransferFrom(_from, _from, refundAmount);
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

        ERC20 token = ERC20(Council(councilAddress).token());
        uint256 succeed = 0;
        for(uint i = 0; i < supports.length; i++) {
            if (!supports[i].refund && succeed < _count)
            {
                require(fundRise >= supports[i].investment);

                supports[i].refund = true;
                token.safeTransfer(supports[i].user, supports[i].investment);
                succeed = succeed.add(1);

                emit Refund(supports[i].user, supports[i].investment, "refund");
            }
        }
    }

    function isOnFunding() public view returns (bool) {
        if (startTime <= block.timestamp.getMs()
            && endTime >= block.timestamp.getMs()
            && fundRise < maxcap)
        {
            return true;
        } else {
            return false;
        }
    }

    event Support(address _from, uint256 supportAmount, uint256 refundAmount);
    event Refund(address, uint256 investment, string reason);
}
