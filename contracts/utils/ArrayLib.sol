pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

library ArrayLib {

    using SafeMath for uint256;

    function merge(address[] target, uint256 startIdx, address[] arr)
    internal
    pure
    {
        require(target.length >= arr.length + startIdx);

        uint idx = startIdx;
        for (uint256 i = 0; i < arr.length; i++) {
            target[idx] = arr[i];
            idx = idx.add(1);
        }
    }

    function merge(uint256[] target, uint256 startIdx, uint256[] arr)
    internal
    pure
    {
        require(target.length >= arr.length + startIdx);

        uint idx = startIdx;
        for (uint256 i = 0; i < arr.length; i++) {
            target[idx] = arr[i];
            idx = idx.add(1);
        }
    }
}
