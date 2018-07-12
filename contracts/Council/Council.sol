pragma solidity ^0.4.24;

import "contracts/utils/ExtendsOwnable.sol";

contract Council is ExtendsOwnable {
    uint256 public cpRate;
    uint256 public translatorRate;
    uint256 public deposit;

    constructor(
        uint256 _cpRate,
        uint256 _translatorRate,
        uint256 _deposit
    ) public {
        require(_cpRate > 0 && _translatorRate > 0 && _deposit > 0);

        cpRate = _cpRate;
        translatorRate = _translatorRate;
        deposit = _deposit;

        emit RegisterCouncil(msg.sender, _cpRate, _translatorRate, _deposit);
    }

    function setCpRate(uint256 _cpRate) external onlyOwner {
        require(_cpRate > 0);

        cpRate = _cpRate;

        emit ChangeDistributionRate(msg.sender, "cp rate");
    }

    function setTranslatorRate(uint256 _translatorRate) external onlyOwner {
        require(_translatorRate > 0);

        translatorRate = _translatorRate;

        emit ChangeDistributionRate(msg.sender, "translator rate");
    }

    function setDeposit(uint256 _deposit) external onlyOwner {
        require(_deposit > 0);

        deposit = _deposit;

        emit ChangeDistributionRate(msg.sender, "deposit");
    }

    event RegisterCouncil(address _addr, uint256 _cpRate, uint256 _translatorRate, uint256 _deposit);
    event ChangeDistributionRate(address _addr, string _name);
}
