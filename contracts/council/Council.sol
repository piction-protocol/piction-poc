pragma solidity ^0.4.24;

import "contracts/utils/ExtendsOwnable.sol";

/**
 * @title Council contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Council is ExtendsOwnable {
    uint256 public cdRate;
    uint256 public deposit;
    address public token;
    address public userPaybackPool;
    uint256 public userPaybackRate;
    address public roleManager;
    address public contentsManager;

    modifier validRange(uint256 _value) {
        require(_value > 0);
        _;
    }

    modifier validAddress(address _account) {
        require(_account != address(0));
        require(_account != address(this));
        _;
    }

    constructor(
        uint256 _cdRate,
        uint256 _deposit,
        address _token,
        address _userPaybackPool,
        uint256 _userPaybackRate
    ) public {
        require(_cdRate > 0 && _deposit > 0 && _userPaybackRate > 0);
        require(_token != address(0) && _token != address(this));
        require(_userPaybackPool != address(0) && _userPaybackPool != address(this));

        cdRate = _cdRate;
        deposit = _deposit;
        token = _token;
        userPaybackPool = _userPaybackPool;
        userPaybackRate = _userPaybackRate;

        emit RegisterCouncil(msg.sender, _cdRate, _deposit, _token, _userPaybackPool, _userPaybackRate);
    }

    function setCdRate(uint256 _cdRate) external onlyOwner validRange(_cdRate) {
        cdRate = _cdRate;

        emit ChangeDistributionRate(msg.sender, "cd rate", _cdRate);
    }

    function setDeposit(uint256 _deposit) external onlyOwner validRange(_deposit) {
        deposit = _deposit;

        emit ChangeDistributionRate(msg.sender, "deposit", _deposit);
    }

    function setUserPaybackPool(address _userPaybackPool) external onlyOwner validAddress(_userPaybackPool) {
        userPaybackPool = _userPaybackPool;

        emit ChangeAddress(msg.sender, "user payback pool", _userPaybackPool);
    }

    function setUserPaybackRate(uint256 _userPaybackRate) external onlyOwner validRange(_userPaybackRate) {
        userPaybackRate = _userPaybackRate;

        emit ChangeDistributionRate(msg.sender, "user payback rate", _userPaybackRate);
    }

    function setRoleManager(address _roleManager) external onlyOwner validAddress(_roleManager) {
        roleManager = _roleManager;

        emit ChangeAddress(msg.sender, "role manager", _roleManager);
    }

    function setContentsManager(address _contentsManager) external onlyOwner validAddress(_contentsManager) {
        contentsManager = _contentsManager;

        emit ChangeAddress(msg.sender, "contents manager", _contentsManager);
    }

    event RegisterCouncil(address _sender, uint256 _cdRate, uint256 _deposit, address _token, address _userPaybackPool, uint256 _userPaybackRate);
    event ChangeDistributionRate(address _sender, string _name, uint256 _value);
    event ChangeAddress(address _sender, string addressName, address _addr);
}
