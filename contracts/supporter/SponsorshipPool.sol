pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

contract SponsorshipPool {
    using SafeERC20 for ERC20;

    struct Supporter {
        address user;
        uint256 investment;
        uint256 collection;
        bool refund;
    }

    ERC20 pxlToken;

    constructor(address _tokenAddress, uint256 _stripPeriod) {
        pxlToken = ERC20(_tokenAddress);
        stripPeriod = _stripPeriod;
    }

    //참여한 서포터 목록
    Supporter[] supports;
    //연재 총 기간
    uint256 stripPeriod;
    //모집된 금액
    uint256 fundRise;
    //지급된 월수
    uint256 releaseCount;
    //CP에게 지급된 양
    uint256 releaseAmount;

    ERC20 pxlToken;

    //todo
    //voting

    //todo
    //monthly payment
    function releaseMonthly() {

        //check

        //safeTransfer to cp
    }
}
