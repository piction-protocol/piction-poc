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
import "contracts/utils/ParseLib.sol";

contract PxlDistributor is Ownable, ContractReceiver, ValidValue {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    struct DistributionDetail {
        address transferAddress;
        uint256 tokenAmount;
        bool isCustomToken;
        string param;
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

    function receiveApproval(address _from, uint256 _value, address _token, string  _jsonData)
        public
    {
        require(address(this) != _from);
        require(address(token) == _token);

        uint256 returnValue;
        JsmnSolLib.Token[] memory tokens;

        (returnValue, tokens) = ParseLib.getJsonToTokens(_jsonData, PURCHASE_PARAM_COUNT);

        if(returnValue > 0) {
            emit InvalidJsonParameter(msg.sender, _value);
            return;
        }

        // clear DistributionDetail array
        clearDistributionDetail();

        require(customValidAddress(ParseLib.getJsonToCdAddr(tokens, _jsonData)));
        require(customValidAddress(ParseLib.getJsonToContentAddr(tokens, _jsonData)));

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
                    ParseLib.getJsonToCdAddr(tokens, _jsonData), tempVar, false, "")
            );

            //user payback pool amount
            tempVar = getRateToPxlAmount(_value, council.getUserPaybackRate());
            compareAmount = compareAmount.sub(tempVar);
            distribution.push(
                DistributionDetail(
                    council.getUserPaybackPool(), tempVar, true, ParseLib.addressToString(_from))
            );

            //deposit amount
            tempVar = getRateToPxlAmount(_value, council.getDepositRate());
            compareAmount = compareAmount.sub(tempVar);
            distribution.push(
                DistributionDetail(
                    council.getDepositPool(), tempVar, true, ParseLib.addressToString(ParseLib.getJsonToContentAddr(tokens, _jsonData)))
            );

            // marketer amount
            if(ParseLib.getJsonToMarketerAddr(tokens, _jsonData) != address(0)) {
                tempVar = getRateToPxlAmount(_value, getMarketerRate(tokens, _jsonData));
                compareAmount = compareAmount.sub(tempVar);
                distribution.push(
                    DistributionDetail(
                        ParseLib.getJsonToMarketerAddr(tokens, _jsonData), tempVar, false, "")
                );
            }

            //supporter amount
            compareAmount = compareAmount.sub(supportersAmount(tokens, _jsonData, compareAmount));

            // cp amount
            if(compareAmount > 0) {
                distribution.push(
                    DistributionDetail(
                        ContentInterface(
                            ParseLib.getJsonToContentAddr(tokens, _jsonData)).getWriter(), compareAmount, false, "")
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
        ContentInterface(ParseLib.getJsonToContentAddr(tokens, _jsonData)).episodePurchase(ParseLib.getJsonToEpisodeIndex(tokens, _jsonData), _from, _value);
    }

    function supportersAmount(JsmnSolLib.Token[] _tokens, string _jsonData, uint256 _amount)
        private
        returns (uint256 compareAmount)
    {
        FundManagerInterface fund = FundManagerInterface(council.getFundManager());
        address[] memory fundAddress = fund.getFunds(ParseLib.getJsonToContentAddr(_tokens, _jsonData));

        for(uint256 i = 0 ; i < fundAddress.length ; i ++){
            if(compareAmount >= _amount) {
                break;
            }

            (address[] memory supporterAddress, uint256[] memory supporterAmount) = fund.distribution(fundAddress[i], _amount);

            for(uint256 j = 0 ; j < supporterAddress.length ; j++) {
                compareAmount = compareAmount.add(supporterAmount[j]);
                distribution.push(DistributionDetail(supporterAddress[j], supporterAmount[j], false, ""));
            }
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

    function getMarketerRate(JsmnSolLib.Token[] _tokens, string _jsonData)
        private
        view
        returns (uint256 rate)
    {
        uint256 contentRate = ContentInterface(ParseLib.getJsonToContentAddr(_tokens, _jsonData)).getMarketerRate();

        rate = (contentRate > 0) ? contentRate : council.getMarketerDefaultRate();
    }

    function transferDistributePxl(address _to, uint256 _amount, bool _isCustom, string _param)
        private
    {
        if(_isCustom) {
            CustomToken(address(token)).approveAndCall(_to, _amount, _param);
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
