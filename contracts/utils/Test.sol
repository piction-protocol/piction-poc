pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "contracts/utils/BytesLib.sol";

contract Test {
    using SafeMath for uint256;

    uint256 public constant decimals = 18;

    function testAddress(address one, address two, address three, uint256 amount) external pure returns(bytes, address, address, address, uint256) {
        bytes memory userOne = BytesLib.toBytes(one);
        bytes memory userTwo = BytesLib.toBytes(two);
        bytes memory userThree = BytesLib.toBytes(three);
        bytes memory value = BytesLib.toBytes(amount);

        bytes memory temp = BytesLib.concat(userOne, userTwo);
        temp = BytesLib.concat(temp, userThree);
        bytes memory concatBytes = BytesLib.concat(temp, value);

        return (concatBytes, BytesLib.toAddress(concatBytes, 0), BytesLib.toAddress(concatBytes, 20), BytesLib.toAddress(concatBytes, 40), BytesLib.toUint(concatBytes, 60));
    }

}
