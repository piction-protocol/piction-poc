var RoleManager = artifacts.require("RoleManager");
var Council = artifacts.require("Council");

module.exports = function(deployer) {
  deployer.deploy(RoleManager);
};
