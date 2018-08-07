var Council = artifacts.require("Council");
var UserPaybackPool = artifacts.require("UserPaybackPool");
var DepositPool = artifacts.require("DepositPool");
var RoleManager = artifacts.require("RoleManager");
var ContentsManager = artifacts.require("ContentsManager");
var FundManager = artifacts.require("FundManager");
var PxlDistributor = artifacts.require("PxlDistributor");
var Marketer = artifacts.require("Marketer");
var Report = artifacts.require("Report");

module.exports = function (deployer) {
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
      FundManager.address
    );
  });
};
