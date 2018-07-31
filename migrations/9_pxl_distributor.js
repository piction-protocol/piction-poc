var PxlDistributor = artifacts.require("PxlDistributor");
var Council = artifacts.require("Council");

module.exports = function(deployer) {
  deployer.deploy(PxlDistributor, Council.address);
};
