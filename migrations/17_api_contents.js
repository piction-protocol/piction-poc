var ApiContents = artifacts.require("ApiContents");
var ContentsManager = artifacts.require("ContentsManager");
var Council = artifacts.require("Council");

module.exports = function (deployer) {
  deployer.deploy(ApiContents, Council.address, ContentsManager.address);
};
