var FundManager = artifacts.require("FundManager");
var Council = artifacts.require("Council");

module.exports = function(deployer) {
  deployer.deploy(FundManager, Council.address);
};
