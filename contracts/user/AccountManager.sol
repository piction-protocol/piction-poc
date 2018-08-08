pragma solidity ^0.4.24;

import "contracts/council/CouncilInterface.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

contract AccountManager {
	using SafeERC20 for ERC20;

	mapping(string => address) userNameToAddress;
	mapping(address => string) addressToUserName;

	modifier validAddress(address _account) {
		require(_account != address(0));
		require(_account != address(this));
		_;
	}

	address council;
	uint256 airdropAmount;

	constructor (address _council, uint256 _airdropAmount) public {
		council = _council;
		airdropAmount = _airdropAmount;
	}

	function createAccount(string _userName) public validAddress(msg.sender) {
		require(userNameToAddress[_userName] == address(0));
		require(bytes(addressToUserName[msg.sender]).length == 0);

		userNameToAddress[_userName] = msg.sender;
		addressToUserName[msg.sender] = _userName;

		// POC airdrop
		ERC20 token = ERC20(CouncilInterface(council).getToken());
		if (airdropAmount > 0 && token.balanceOf(address(this)) >= airdropAmount) {
			token.safeTransfer(msg.sender, airdropAmount);
		}
	}

	function getUserName(address _addr) public validAddress(_addr) view returns (string) {
		return addressToUserName[_addr];
	}

	function getUserAddress(string _userName) public view returns (address) {
		return userNameToAddress[_userName];
	}
}
