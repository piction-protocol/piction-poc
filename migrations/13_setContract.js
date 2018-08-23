var Council = artifacts.require("Council");
var PXL = artifacts.require("PXL");
var UserPaybackPool = artifacts.require("UserPaybackPool");
var DepositPool = artifacts.require("DepositPool");
var RoleManager = artifacts.require("RoleManager");
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
    instance.mint(100000000 * Math.pow(10, 18));
    instance.transfer(AccountManager.address, amount);
  });

  RoleManager.deployed().then(function (instance) {
    instance.addAddressToRole(PxlDistributor.address, 'PXL_DISTRIBUTOR');
  });

  Council.deployed().then(function (instance) {
    const decimals = Math.pow(10, 18);
    const cdRate = 0.15 * decimals;
    const depositRate = 0.03 * decimals;
    const userPaybackRate = 0.02 * decimals;
    const reportRewardRate = 0.01 * decimals;
    const marketerDefaultRate = 0.15 * decimals;

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
      RoleManager.address,
      ContentsManager.address,
      FundManager.address,
      AccountManager.address
    );
  });
};
