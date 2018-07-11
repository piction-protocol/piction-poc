pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

library BlockTimeMs {
    using SafeMath for uint256;

    function getMs(uint s) internal pure returns(uint ms) {
        return s.mul(1000);
    }
}
