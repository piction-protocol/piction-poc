var Council = artifacts.require("Council");
var PXL = artifacts.require("PXL");
var UserPaybackPool = artifacts.require("UserPaybackPool");
var DepositPool = artifacts.require("DepositPool");
var SupporterPool = artifacts.require("SupporterPool");
var ContentsManager = artifacts.require("ContentsManager");
var FundManager = artifacts.require("FundManager");
var AccountManager = artifacts.require("AccountManager");
var PxlDistributor = artifacts.require("PxlDistributor");
var Marketer = artifacts.require("Marketer");
var Report = artifacts.require("Report");
var ApiReport = artifacts.require("ApiReport");
var ApiContents = artifacts.require("ApiContents");
var ApiFund = artifacts.require("ApiFund");

module.exports = function (deployer, networks, accounts) {

  // airdrop
  PXL.deployed().then(function (instance) {
    const amount = 10000000 * Math.pow(10, 18);
    instance.mint(amount);
    instance.transfer(AccountManager.address, amount);
    instance.unlock();
  });

  Council.deployed().then(function (instance) {
    const decimals = Math.pow(10, 18);

    const initialDeposit = 10 * decimals;
    const reportRegistrationFee = 10 * decimals;
    const fundAvailable = true;

    const cdRate = 0.15 * decimals;
    const depositRate = 0.03 * decimals;
    const userPaybackRate = 0.02 * decimals;
    const reportRewardRate = 0.01 * decimals;
    const marketerDefaultRate = 0.15 * decimals;

    instance.initialValue(
      initialDeposit,
      reportRegistrationFee,
      fundAvailable
    );

    instance.initialRate(
      cdRate,
      depositRate,
      userPaybackRate,
      reportRewardRate,
      marketerDefaultRate
    );

    instance.initialPictionAddress(
      UserPaybackPool.address,
      DepositPool.address,
      SupporterPool.address,
      PxlDistributor.address,
      Marketer.address,
      Report.address,
      accounts[0]
    );

    instance.initialManagerAddress(
      ContentsManager.address,
      FundManager.address,
      AccountManager.address
    );

    instance.initialApiAddress(
      ApiContents.address,
      ApiReport.address,
      ApiFund.address
    );
  });

  AccountManager.deployed().then(function (instance) {
    instance.createNewAccount('skkwon', 'a123a123', '0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3', '0x627306090abab3a6e1400e9345bc60c78a8bef57');
  });
};
