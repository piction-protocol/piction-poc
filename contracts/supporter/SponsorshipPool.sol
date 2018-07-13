pragma solidity ^0.4.24;

contract SponsorshipPool {


    struct Supporter {
        address user;
        uint256 investment;
        uint256 collection;
        uint256 distributionRate;
        bool refund;
    }

    Supporter[] supports;

    //total amount
    //release amount

    //todo
    //voting

    //todo
    //monthly payment

}
