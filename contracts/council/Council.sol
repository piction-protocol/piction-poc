pragma solidity ^0.4.24;

import "contracts/utils/ExtendsOwnable.sol";

/**
 * @title Council contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Council is ExtendsOwnable {
    uint256 public cdRate;
    uint256 public depositRate;
    uint256 public initialDeposit;
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
        uint256 _depositRate,
        uint256 _initialDeposit,
        address _token,
        address _userPaybackPool,
        uint256 _userPaybackRate)
        public
        validRange(_cdRate)
        validRange(_depositRate)
        validRange(_initialDeposit)
        validRange(_userPaybackRate)
        validAddress(_token)
        validAddress(_userPaybackPool)
    {
        cdRate = _cdRate;
        depositRate = _depositRate;
        initialDeposit = _initialDeposit;
        token = _token;
        userPaybackPool = _userPaybackPool;
        userPaybackRate = _userPaybackRate;

        emit RegisterCouncil(msg.sender, _cdRate, _depositRate, _initialDeposit, _token, _userPaybackPool, _userPaybackRate);
    }

    function setCdRate(uint256 _cdRate) external onlyOwner validRange(_cdRate) {
        cdRate = _cdRate;

        emit ChangeDistributionRate(msg.sender, "cd rate", _cdRate);
    }

    function setDepositRate(uint256 _depositRate) external onlyOwner validRange(_depositRate) {
        depositRate = _depositRate;

        emit ChangeDistributionRate(msg.sender, "deposit rate", _depositRate);
    }

    function setInitialDeposit(uint256 _initialDeposit) external onlyOwner validRange(_initialDeposit) {
        initialDeposit = _initialDeposit;

        emit ChangeDistributionRate(msg.sender, "initial deposit", _initialDeposit);
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

    event RegisterCouncil(address _sender, uint256 _cdRate, uint256 _deposit, uint256 _initialDeposit, address _token, address _userPaybackPool, uint256 _userPaybackRate);
    event ChangeDistributionRate(address _sender, string _name, uint256 _value);
    event ChangeAddress(address _sender, string addressName, address _addr);
}
