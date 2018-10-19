var SupporterPool = artifacts.require("SupporterPool");
var Council = artifacts.require("Council");

module.exports = function (deployer) {
  deployer.deploy(SupporterPool, Council.address);
};
