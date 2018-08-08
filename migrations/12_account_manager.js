var AccountManager = artifacts.require("AccountManager");

module.exports = function(deployer) {
  deployer.deploy(AccountManager);
};
