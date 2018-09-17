pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/interface/ICustomToken.sol";
import "contracts/interface/IContractReceiver.sol";

import "contracts/utils/ExtendsOwnable.sol";

/**
 * @title PXL implementation based on StandardToken ERC-20 contract.
 *
 * @author Charls Kim - <cs.kim@battleent.com>
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
contract PXL is StandardToken, ICustomToken, ExtendsOwnable {
    using SafeMath for uint256;

    // PXL 토큰 기본 정보
    string public constant name = "Pixel";
    string public constant symbol = "PXL";
    uint256 public constant decimals = 18;
    uint256 public totalSupply;

    // PXL 토큰 글로벌 락 변수
    bool isTransferable = false;

    function() public payable {
        revert();
    }

    /**
     * @dev PXL 글로벌 락 해제
     *
     * @notice 거래소 상장 후 락 해제
     */
    function unlock() external onlyOwner {
        isTransferable = true;
    }

    function getTokenTransferable() external view returns (bool) {
        return isTransferable;
    }

    /**
     * @dev 토큰 대리 전송을 위한 함수
     *
     * @notice 토큰 전송이 불가능 할 경우 전송 실패
     * @param _from 토큰을 가지고 있는 지갑 주소
     * @param _to 대리 전송 권한을 부여할 지갑 주소
     * @param _value 대리 전송할 토큰 수량
     * @return bool 타입의 토큰 대리 전송 권한 성공 여부
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(isTransferable || owners[msg.sender]);
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev PXL 토큰 전송 함수
     *
     * @notice 토큰 전송이 불가능 할 경우 전송 실패
     * @param _to 토큰을 받을 지갑 주소
     * @param _value 전송할 토큰 수량
     * @return bool 타입의 전송 결과
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(isTransferable || owners[msg.sender]);
        return super.transfer(_to, _value);
    }

    /**
     * @dev PXL 전송과 데이터를 함께 사용하는 함수
     *
     * @notice ICustomToken 인터페이스 활용
     * @notice _to 주소가 컨트랙트인 경우만 사용 가능
     * @notice 토큰과 데이터를 받으려면 해당 컨트랙트에 receiveApproval 함수 구현 필요
     * @param _to 토큰을 전송하고 함수를 실행할 컨트랙트 주소
     * @param _value 전송할 토큰 수량
     * @return bool 타입의 처리 결과
     */
    function approveAndCall(address _to, uint256 _value, bytes _data) public returns (bool) {
        require(isTransferable || owners[msg.sender]);
        require(_to != address(0) && _to != address(this));
        require(balances[msg.sender] >= _value);

        if(approve(_to, _value) && isContract(_to)) {
            IContractReceiver receiver = IContractReceiver(_to);
            receiver.receiveApproval(msg.sender, _value, address(this), _data);
            emit ApproveAndCall(msg.sender, _to, _value, _data);

            return true;
        }
    }

    /**
     * @dev 토큰 발행 함수
     * @param _amount 발행할 토큰 수량
     */
    function mint(uint256 _amount) onlyOwner public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);

        emit Mint(msg.sender, _amount);
        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }

    /**
     * @dev 토큰 소멸 함수
     * @param _amount 소멸할 토큰 수량
     */
    function burn(uint256 _amount) onlyOwner public {
        require(_amount <= balances[msg.sender]);

        totalSupply = totalSupply.sub(_amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);

        emit Burn(msg.sender, _amount);
    }

    /**
     * @dev 컨트랙트 확인 함수
     * @param _addr 컨트랙트 주소
     */
    function isContract(address _addr) private view returns (bool) {
        uint256 length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

    event Mint(address indexed _to, uint256 _amount);
    event Burn(address indexed _from, uint256 _amount);
}
