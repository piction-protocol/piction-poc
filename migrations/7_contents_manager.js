var ContentsManager = artifacts.require("ContentsManager");
var Council = artifacts.require("Council");

module.exports = function(deployer) {
  deployer.deploy(ContentsManager, Council.address);
};
