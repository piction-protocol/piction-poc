var UserPaybackPool = artifacts.require("UserPaybackPool");
var Council = artifacts.require("Council");

module.exports = function(deployer) {
  deployer.deploy(UserPaybackPool, Council.address);
};
