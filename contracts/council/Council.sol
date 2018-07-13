pragma solidity ^0.4.24;

import "contracts/utils/ExtendsOwnable.sol";

/**
 * @title Council contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Council is ExtendsOwnable {
    uint256 public cpRate;
    uint256 public translatorRate;
    uint256 public deposit;
    address public token;

    modifier validRange(uint256 _value) {
        require(_value > 0);
        _;
    }

    constructor(
        uint256 _cpRate,
        uint256 _translatorRate,
        uint256 _deposit,
        address _token
    ) public {
        require(_cpRate > 0 && _translatorRate > 0 && _deposit > 0);
        require(_token != address(0) && _token != address(this));

        cpRate = _cpRate;
        translatorRate = _translatorRate;
        deposit = _deposit;
        token = _token;

        emit RegisterCouncil(msg.sender, _cpRate, _translatorRate, _deposit, _token);
    }

    function setCpRate(uint256 _cpRate) external onlyOwner validRange(_cpRate) {
        cpRate = _cpRate;

        emit ChangeDistributionRate(msg.sender, "cp rate");
    }

    function setTranslatorRate(uint256 _translatorRate) external onlyOwner validRange(_translatorRate) {
        translatorRate = _translatorRate;

        emit ChangeDistributionRate(msg.sender, "translator rate");
    }

    function setDeposit(uint256 _deposit) external onlyOwner validRange(_deposit) {
        deposit = _deposit;

        emit ChangeDistributionRate(msg.sender, "deposit");
    }

    event RegisterCouncil(address _addr, uint256 _cpRate, uint256 _translatorRate, uint256 _deposit, address _token);
    event ChangeDistributionRate(address _addr, string _name);
}
