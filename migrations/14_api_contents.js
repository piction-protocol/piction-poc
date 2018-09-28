var ApiContents = artifacts.require("ApiContents");
var Council = artifacts.require("Council");

module.exports = function (deployer) {
  deployer.deploy(ApiContents, Council.address);
};
