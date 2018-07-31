var Contract = artifacts.require("Council");
var PXL = artifacts.require("PXL");

module.exports = function (deployer) {
    deployer.deploy(Contract, PXL.address);
};
