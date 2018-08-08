var Contract = artifacts.require("PXL");
var AccountManager = artifacts.require("AccountManager");

module.exports = function (deployer) {
  const amount = 10000000 * Math.pow(10, 18);
  deployer.deploy(Contract, amount).then(function (instance) {
    instance.unlock();
  });
};
