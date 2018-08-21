pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "contracts/token/CustomToken.sol";
import "contracts/council/CouncilInterface.sol";
import "contracts/contents/ContentInterface.sol";
import "contracts/marketer/MarketerInterface.sol";
import "contracts/token/ContractReceiver.sol";
import "contracts/supporter/FundManagerInterface.sol";
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
    CouncilInterface council;
    DistributionDetail[] distribution;

    constructor(address _councilAddr)
        public
        validAddress(_councilAddr)
    {
        council = CouncilInterface(_councilAddr);
        token = ERC20(council.getToken());
    }

    /* function receiveApproval(address _from, uint256 _value, address _token, address[]  _address, uint256 _index)
        public
    {
        require(address(this) != _from);
        require(address(token) == _token);
        require(_address.length >= 2);

        // clear DistributionDetail array
        clearDistributionDetail();

        address cdAddr = _address[0];
        address contentAddr = _address[1];
        address marketerAddr = _address[2];
        uint256 idx = _index;

        require(customValidAddress(cdAddr));
        require(customValidAddress(contentAddr));

        // paid contents
        if(_value > 0) {
            require(token.balanceOf(_from) >= _value);
            token.safeTransferFrom(_from, address(this), _value);

            uint256 tempVar;
            uint256 compareAmount = _value;

            //cd amount
            tempVar = getRateToPxlAmount(_value, council.getCdRate());
            compareAmount = compareAmount.sub(tempVar);
            distribution.push(
                DistributionDetail(
                    cdAddr, tempVar, false, address(0))
            );

            //user payback pool amount
            tempVar = getRateToPxlAmount(_value, council.getUserPaybackRate());
            compareAmount = compareAmount.sub(tempVar);
            distribution.push(
                DistributionDetail(
                    council.getUserPaybackPool(), tempVar, true, _from)
            );

            //deposit amount
            tempVar = getRateToPxlAmount(_value, council.getDepositRate());
            compareAmount = compareAmount.sub(tempVar);
            distribution.push(
                DistributionDetail(
                    council.getDepositPool(), tempVar, true, contentAddr)
            );

            // marketer amount
            if(marketerAddr != address(0)) {
                tempVar = getRateToPxlAmount(_value, getMarketerRate(contentAddr));
                compareAmount = compareAmount.sub(tempVar);
                distribution.push(
                    DistributionDetail(
                        marketerAddr, tempVar, false, address(0))
                );
            }

            //supporter amount
            compareAmount = compareAmount.sub(supportersAmount(contentAddr, compareAmount));

            // cp amount
            if(compareAmount > 0) {
                distribution.push(
                    DistributionDetail(
                        ContentInterface(contentAddr).getWriter(), compareAmount, false, address(0))
                );
                compareAmount = 0;
            }

            // transfer
            for(uint256 i  = 0 ; i < distribution.length ; i ++) {
                transferDistributePxl(
                    distribution[i].transferAddress,
                    distribution[i].tokenAmount,
                    distribution[i].isCustomToken,
                    distribution[i].param
                );
            }
        }

        // update episode purchase
        ContentInterface(contentAddr).episodePurchase(idx, _from, _value);
    } */

    function receiveApproval(address _from, uint256 _value, address _token, bytes _data)
        public
    {
        require(address(this) != _from);
        require(address(token) == _token);

        // clear DistributionDetail array
        clearDistributionDetail();

        address cdAddr = _data.toAddress(0);
        address contentAddr = _data.toAddress(20);
        address marketerAddr = _data.toAddress(40);
        uint256 idx = _data.toUint(60);

        require(customValidAddress(cdAddr));
        require(customValidAddress(contentAddr));

        // paid contents
        if(_value > 0) {
            require(token.balanceOf(_from) >= _value);
            token.safeTransferFrom(_from, address(this), _value);

            uint256 tempVar;
            uint256 compareAmount = _value;

            //cd amount
            tempVar = getRateToPxlAmount(_value, council.getCdRate());
            compareAmount = compareAmount.sub(tempVar);
            distribution.push(
                DistributionDetail(
                    cdAddr, tempVar, false, address(0))
            );

            //user payback pool amount
            tempVar = getRateToPxlAmount(_value, council.getUserPaybackRate());
            compareAmount = compareAmount.sub(tempVar);
            distribution.push(
                DistributionDetail(
                    council.getUserPaybackPool(), tempVar, true, _from)
            );

            //deposit amount
            tempVar = getRateToPxlAmount(_value, council.getDepositRate());
            compareAmount = compareAmount.sub(tempVar);
            distribution.push(
                DistributionDetail(
                    council.getDepositPool(), tempVar, true, contentAddr)
            );

            // marketer amount
            if(marketerAddr != address(0)) {
                tempVar = getRateToPxlAmount(_value, getMarketerRate(contentAddr));
                compareAmount = compareAmount.sub(tempVar);
                distribution.push(
                    DistributionDetail(
                        marketerAddr, tempVar, false, address(0))
                );
            }

            //supporter amount
            compareAmount = compareAmount.sub(supportersAmount(contentAddr, compareAmount));

            // cp amount
            if(compareAmount > 0) {
                distribution.push(
                    DistributionDetail(
                        ContentInterface(contentAddr).getWriter(), compareAmount, false, address(0))
                );
                compareAmount = 0;
            }

            // transfer
            for(uint256 i  = 0 ; i < distribution.length ; i ++) {
                transferDistributePxl(
                    distribution[i].transferAddress,
                    distribution[i].tokenAmount,
                    distribution[i].isCustomToken,
                    distribution[i].param
                );
            }
        }

        // update episode purchase
        ContentInterface(contentAddr).episodePurchase(idx, _from, _value);
    }

    function supportersAmount(address _content, uint256 _amount)
        private
        returns (uint256 compareAmount)
    {
        uint256 amount = _amount;

        FundManagerInterface fund = FundManagerInterface(council.getFundManager());
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

    function clearDistributionDetail()
        private
    {
        delete distribution;
    }

    function getRateToPxlAmount(uint256 _amount, uint256 _rate)
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
        uint256 contentRate = ContentInterface(_content).getMarketerRate();

        rate = (contentRate > 0) ? contentRate : council.getMarketerDefaultRate();
    }


    function transferDistributePxl(address _to, uint256 _amount, bool _isCustom, address _param)
        private
    {
        if(_isCustom) {
            CustomToken(address(token)).approveAndCall(_to, _amount, BytesLib.toBytes(_param));
        } else {
            token.safeTransfer(_to, _amount);
        }

        emit TransferDistributePxl(_to, _amount);
    }

    function customValidAddress(address _address)
        private
        view
        returns (bool)
    {
            return (_address != address(this) && _address != address(0)) ? true : false;
    }

    event InvalidJsonParameter(address _sender, uint256 _pxl);
    event TransferDistributePxl(address indexed _to, uint256 _pxlAmount);
}
