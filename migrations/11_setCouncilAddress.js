var Council = artifacts.require("Council");
var UserPaybackPool = artifacts.require("UserPaybackPool");
var DepositPool = artifacts.require("DepositPool");
var RoleManager = artifacts.require("RoleManager");
var ContentsManager = artifacts.require("ContentsManager");
var FundManager = artifacts.require("FundManager");
var PxlDistributor = artifacts.require("PxlDistributor");
var Marketer = artifacts.require("Marketer");

module.exports = function (deployer) {
  Council.deployed().then(function (instance) {
    instance.initialAddress(
      UserPaybackPool.address,
      DepositPool.address,
      RoleManager.address,
      ContentsManager.address,
      FundManager.address,
      PxlDistributor.address,
      Marketer.address
    );
  });
};
