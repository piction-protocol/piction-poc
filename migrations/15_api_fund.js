var ApiFund = artifacts.require("ApiFund");
var Council = artifacts.require("Council");

module.exports = function (deployer) {
  deployer.deploy(ApiFund, Council.address);
};
