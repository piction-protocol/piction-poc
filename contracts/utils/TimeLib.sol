pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

library TimeLib {
    using SafeMath for uint256;

    function currentTime() internal view returns (uint ms) {
        return block.timestamp.mul(1000);
    }

    function between(uint t, uint s, uint e) internal pure returns (bool) {
        return s <= t && t <= e;
    }
}
