pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IContent.sol";
import "contracts/interface/IMarketer.sol";
import "contracts/interface/IFundManager.sol";
import "contracts/interface/IAccountManager.sol";

import "contracts/token/CustomToken.sol";
import "contracts/token/ContractReceiver.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/BytesLib.sol";

contract PxlDistributor is Ownable, ContractReceiver, ValidValue {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using BytesLib for bytes;

    struct DistributionDetail {
        address transferAddress;
        uint256 tokenAmount;
        bool isCustomToken;
        address param;
    }

    uint256 public constant DECIMALS = 10 ** 18;
    uint256 public constant PURCHASE_PARAM_COUNT = 9;

    ERC20 token;
    ICouncil council;
    DistributionDetail[] distribution;

    constructor(address _councilAddr)
        public
        validAddress(_councilAddr)
    {
        council = ICouncil(_councilAddr);
        token = ERC20(council.getToken());
    }

    function receiveApproval(address _from, uint256 _value, address _token, bytes _data)
        public
    {
        require(address(this) != _from);
        require(address(token) == _token);

        address cdAddr = _data.toAddress(0);
        address contentAddr = _data.toAddress(20);
        address marketerAddr = _data.toAddress(40);
        uint256 idx = _data.toUint(60);

        require(_customValidAddress(cdAddr));
        require(_customValidAddress(contentAddr));

        // paid contents
        if(_value > 0) {
            require(token.balanceOf(_from) >= _value);
            token.safeTransferFrom(_from, address(this), _value);

            // clear DistributionDetail array
            _clearDistributionDetail();

            _purchaseTokenDistribution(_from, cdAddr, contentAddr, marketerAddr, _value);
        }

        // update episode purchase
        IContent(contentAddr).episodePurchase(idx, _from, _value);

        // update user purchase
        IAccountManager(council.getAccountManager()).setPurchaseContentsAddress(contentAddr, _from);
    }

    function _purchaseTokenDistribution(
        address _buyerAddress,
        address _contentDistributor,
        address _contentAddress,
        address _marketerAddress,
        uint256 _purchaseAmount
    )
        private
    {
        uint256 tempVar;
        uint256 compareAmount = _purchaseAmount;

        //cd amount
        tempVar = _getRateToPxlAmount(_purchaseAmount, council.getCdRate());
        compareAmount = compareAmount.sub(tempVar);
        distribution.push(
            DistributionDetail(
                _contentDistributor, tempVar, false, address(0))
        );

        //user payback pool amount
        tempVar = _getRateToPxlAmount(_purchaseAmount, council.getUserPaybackRate());
        compareAmount = compareAmount.sub(tempVar);
        distribution.push(
            DistributionDetail(
                council.getUserPaybackPool(), tempVar, true, _buyerAddress)
        );

        //deposit amount
        tempVar = _getRateToPxlAmount(_purchaseAmount, council.getDepositRate());
        compareAmount = compareAmount.sub(tempVar);
        distribution.push(
            DistributionDetail(
                council.getDepositPool(), tempVar, true, _contentAddress)
        );

        // marketer amount
        if(_marketerAddress != address(0)) {
            tempVar = _getRateToPxlAmount(_purchaseAmount, getMarketerRate(_contentAddress));
            compareAmount = compareAmount.sub(tempVar);
            distribution.push(
                DistributionDetail(
                    _marketerAddress, tempVar, false, address(0))
            );
        }

        //supporter amount
        compareAmount = compareAmount.sub(_supportersAmount(_contentAddress, compareAmount));

        // cp amount
        if(compareAmount > 0) {
            distribution.push(
                DistributionDetail(
                    IContent(_contentAddress).getWriter(), compareAmount, false, address(0))
            );
            compareAmount = 0;
        }

        // transfer
        for(uint256 i  = 0 ; i < distribution.length ; i ++) {
            _transferDistributePxl(
                distribution[i].transferAddress,
                distribution[i].tokenAmount,
                distribution[i].isCustomToken,
                distribution[i].param
            );
        }
    }

    function _supportersAmount(address _content, uint256 _amount)
        private
        returns (uint256 compareAmount)
    {
        uint256 amount = _amount;

        IFundManager fund = IFundManager(council.getFundManager());
        address[] memory fundAddress = fund.getFunds(_content);

        for(uint256 i = 0 ; i < fundAddress.length ; i ++){
            if(amount == 0) {
                break;
            }

            (address[] memory supporterAddress, uint256[] memory supporterAmount) = fund.distribution(fundAddress[i], amount);

            for(uint256 j = 0 ; j < supporterAddress.length ; j++) {
                compareAmount = compareAmount.add(supporterAmount[j]);
                distribution.push(DistributionDetail(supporterAddress[j], supporterAmount[j], false, address(0)));
            }

            amount = amount.sub(compareAmount);
        }
    }

    function _clearDistributionDetail()
        private
    {
        delete distribution;
    }

    function _getRateToPxlAmount(uint256 _amount, uint256 _rate)
        private
        pure
        returns (uint256)
    {
        return _amount.mul(_rate).div(DECIMALS);
    }

    function getMarketerRate(address _content)
        private
        view
        returns (uint256 rate)
    {
        uint256 contentRate = IContent(_content).getMarketerRate();

        rate = (contentRate > 0) ? contentRate : council.getMarketerDefaultRate();
    }


    function _transferDistributePxl(address _to, uint256 _amount, bool _isCustom, address _param)
        private
    {
        if(_isCustom) {
            CustomToken(address(token)).approveAndCall(_to, _amount, BytesLib.toBytes(_param));
        } else {
            token.safeTransfer(_to, _amount);
        }

        emit TransferDistributePxl(_to, _amount);
    }

    function _customValidAddress(address _address)
        private
        view
        returns (bool)
    {
            return (_address != address(this) && _address != address(0)) ? true : false;
    }

    event InvalidJsonParameter(address _sender, uint256 _pxl);
    event TransferDistributePxl(address indexed _to, uint256 _pxlAmount);
}
