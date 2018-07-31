var DepositPool = artifacts.require("DepositPool");
var Council = artifacts.require("Council");

module.exports = function(deployer) {
  deployer.deploy(DepositPool, Council.address);
};
