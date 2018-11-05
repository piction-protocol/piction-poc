pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IContent.sol";
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
        uint256 tokenAmount;
        bool isCustomToken;
        address transferAddress;
        bytes param;
        string message;
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
        require(address(this) != _from, "Invalid buyer address.");
        require(address(token) == _token, "Invalid Pixel token address.");

        // address cdAddr = _data.toAddress(0);
        // address contentAddr = _data.toAddress(20);
        // uint256 idx = _data.toUint(60);

        //PoC 임시 코드
        address cdAddr = council.getContentsDistributor();
        address contentAddr = _data.toAddress(0);
        uint256 idx = _data.toUint(20);

        require(_customValidAddress(cdAddr), "Invalid contents distributor address.");
        require(_customValidAddress(contentAddr), "Invalid contents address.");

        // paid contents
        if(_value > 0) {
            require(token.balanceOf(_from) >= _value, "Check buyer token amount.");
            CustomToken(address(token)).transferFromPxl(_from, address(this), _value, "에피소드 구매");

            // clear DistributionDetail array
            _clearDistributionDetail();

            _purchaseTokenDistribution(_from, cdAddr, _data, _value);

        }

        // update episode purchase
        IContent(contentAddr).episodePurchase(idx, _from, _value);

        // update user purchase history
        IAccountManager(council.getAccountManager()).setPurchaseHistory(_from, contentAddr, idx, _value);
    }

    function _purchaseTokenDistribution(
        address _buyerAddress,
        address _contentDistributor,
        bytes _data,
        uint256 _purchaseAmount
    )
        private
    {
        uint256 tempVar;
        uint256 compareAmount = _purchaseAmount;
        address _contentAddress = _data.toAddress(0);

        //cd amount
        tempVar = _getRateToPxlAmount(_purchaseAmount, council.getCdRate());
        compareAmount = compareAmount.sub(tempVar);
        distribution.push(
            DistributionDetail(
                tempVar, false, _contentDistributor, new bytes(0), "CD 플랫폼 수수료"
            )
        );

        //user payback pool amount
        bytes memory paybackParam = BytesLib.toBytes(_buyerAddress);
        paybackParam = paybackParam.concat(_data);
        tempVar = _getRateToPxlAmount(_purchaseAmount, council.getUserPaybackRate());
        compareAmount = compareAmount.sub(tempVar);
        distribution.push(
            DistributionDetail(
                tempVar, true, council.getUserPaybackPool(), paybackParam, ""
            )
        );

        //supporter amount
        if(council.getFundAvailable()) {
            compareAmount = compareAmount.sub(_supportersAmount(_contentAddress, compareAmount));
        }

        // cp amount
        if(compareAmount > 0) {
            distribution.push(
                DistributionDetail(
                    compareAmount, false, IContent(_contentAddress).getWriter(), new bytes(0), "컨텐츠 판매 수익"

                )
            );
            compareAmount = 0;
        }

        // transfer
        for(uint256 i = 0 ; i < distribution.length ; i ++) {
            _transferDistributePxl(
                distribution[i].transferAddress,
                distribution[i].tokenAmount,
                distribution[i].isCustomToken,
                distribution[i].param,
                distribution[i].message
            );
        }
    }

    function _supportersAmount(address _content, uint256 _amount)
        private
        returns (uint256 compareAmount)
    {
        uint256 amount = _amount;

        IFundManager fund = IFundManager(council.getFundManager());
        address fundAddress = fund.getFund(_content);

        if(fundAddress == address(0)) {
            return;
        }

        (address[] memory supporterAddress, uint256[] memory supporterAmount) = fund.distribution(fundAddress, amount);

        for(uint256 j = 0 ; j < supporterAddress.length ; j++) {
            if(supporterAmount[j] > 0) {
                compareAmount = compareAmount.add(supporterAmount[j]);
                distribution.push(
                    DistributionDetail(
                        supporterAmount[j], false, supporterAddress[j], new bytes(0), "서포터 수익 배분"
                    )
                );
            }
        }

        amount = amount.sub(compareAmount);
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

    function _transferDistributePxl(address _to, uint256 _amount, bool _isCustom, bytes _param, string message)
        private
    {
        if(_isCustom) {
            CustomToken(address(token)).approveAndCall(_to, _amount, _param);
        } else {
            CustomToken(address(token)).transferPxl(_to, _amount, message);
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
