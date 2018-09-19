var ApiReport = artifacts.require("ApiReport");
var Council = artifacts.require("Council");

module.exports = function (deployer) {
  deployer.deploy(ApiReport, Council.address);
};
