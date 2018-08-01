var Contract = artifacts.require("PXL");

module.exports = function (deployer) {
  deployer.deploy(Contract, 10000000 * Math.pow(10, 18)).then(function (instance) {
        instance.unlock();
  });
};
