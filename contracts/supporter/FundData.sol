pragma solidity ^0.4.24;

library FundData {

    struct Supporter {
        address user;
        uint256 investment;
        uint256 collection;
    }

    enum PoolState {PENDING, PAID, CANCEL_PAYMENT}

    struct Pool {
        uint256 amount;
        uint256 distributionTime;
        uint256 distributedTime;
        PoolState state;
        mapping(address => bool) voting;
    }
}
