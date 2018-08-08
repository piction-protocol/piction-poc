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
    instance.transfer(AccountManager.address, amount);
  });

  Council.deployed().then(function (instance) {

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

    console.log(`Council.address : ${Council.address}`)
  });
};
