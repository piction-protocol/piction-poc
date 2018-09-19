var Council = artifacts.require("Council");
var PXL = artifacts.require("PXL");
var UserPaybackPool = artifacts.require("UserPaybackPool");
var DepositPool = artifacts.require("DepositPool");
var ContentsManager = artifacts.require("ContentsManager");
var FundManager = artifacts.require("FundManager");
var AccountManager = artifacts.require("AccountManager");
var PxlDistributor = artifacts.require("PxlDistributor");
var Marketer = artifacts.require("Marketer");
var Report = artifacts.require("Report");

module.exports = function (deployer) {

  // airdrop
  PXL.deployed().then(function (instance) {
    const amount = 10000000 * Math.pow(10, 18);
    instance.mint(amount);
    instance.transfer(AccountManager.address, amount);
    instance.unlock();
  });

  Council.deployed().then(function (instance) {
    const decimals = Math.pow(10, 18);

    const initialDeposit = 10 * decimals;
    const reportRegistrationFee = 10 * decimals;

    const cdRate = 0.15 * decimals;
    const depositRate = 0.03 * decimals;
    const userPaybackRate = 0.02 * decimals;
    const reportRewardRate = 0.01 * decimals;
    const marketerDefaultRate = 0.15 * decimals;

    instance.initialValue(
      initialDeposit,
      reportRegistrationFee,
    );

    instance.initialRate(
      cdRate,
      depositRate,
      userPaybackRate,
      reportRewardRate,
      marketerDefaultRate
    );

    instance.initialPictionAddress(
      UserPaybackPool.address,
      DepositPool.address,
      PxlDistributor.address,
      Marketer.address,
      Report.address
    );

    instance.initialManagerAddress(
      ContentsManager.address,
      FundManager.address,
      AccountManager.address
    );
  });
};
