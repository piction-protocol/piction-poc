pragma solidity ^0.4.24;

import "contracts/utils/ExtendsOwnable.sol";

/**
 * @title Council contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Council is ExtendsOwnable {
    uint256 public cdRate;
    uint256 public translatorRate;
    uint256 public deposit;
    address public token;
    address public roleManager;
    address public contentManager;

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
        uint256 _translatorRate,
        uint256 _deposit,
        address _token
    ) public {
        require(_cdRate > 0 && _translatorRate > 0 && _deposit > 0);
        require(_token != address(0) && _token != address(this));

        cdRate = _cdRate;
        translatorRate = _translatorRate;
        deposit = _deposit;
        token = _token;

        emit RegisterCouncil(msg.sender, _cdRate, _translatorRate, _deposit, _token);
    }

    function setCdRate(uint256 _cdRate) external onlyOwner validRange(_cdRate) {
        cdRate = _cdRate;

        emit ChangeDistributionRate(msg.sender, "cd rate");
    }

    function setTranslatorRate(uint256 _translatorRate) external onlyOwner validRange(_translatorRate) {
        translatorRate = _translatorRate;

        emit ChangeDistributionRate(msg.sender, "translator rate");
    }

    function setDeposit(uint256 _deposit) external onlyOwner validRange(_deposit) {
        deposit = _deposit;

        emit ChangeDistributionRate(msg.sender, "deposit");
    }

    function setRoleManager(address _roleManager) external onlyOwner validAddress(_roleManager) {
        roleManager = _roleManager;

        emit ChangeAddress(msg.sender, "role manager", _roleManager);
    }

    function setContentManager(address _contentManager) external onlyOwner validAddress(_contentManager) {
        contentManager = _contentManager;

        emit ChangeAddress(msg.sender, "content manager", _contentManager);
    }

    event RegisterCouncil(address _sender, uint256 _cdRate, uint256 _translatorRate, uint256 _deposit, address _token);
    event ChangeDistributionRate(address _sender, string _name);
    event ChangeAddress(address _sender, string addressName, address _addr);
}
