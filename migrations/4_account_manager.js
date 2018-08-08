var AccountManager = artifacts.require("AccountManager");
var Council = artifacts.require("Council");

module.exports = function (deployer) {
  const airdrop = 1000 * Math.pow(10, 18);
  deployer.deploy(AccountManager, Council.address, airdrop);
};
