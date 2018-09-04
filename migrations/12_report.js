var Report = artifacts.require("Report");
var Council = artifacts.require("Council");

module.exports = function (deployer) {
  deployer.deploy(Report, Council.address);
};
