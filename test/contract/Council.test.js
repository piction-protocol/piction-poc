var PXL = artifacts.require("PXL");
var Council = artifacts.require("Council");
var UserPaybackPool = artifacts.require("UserPaybackPool");
var DepositPool = artifacts.require("DepositPool");
var PxlDistributor = artifacts.require("PxlDistributor");
var Marketer = artifacts.require("Marketer");
var Report = artifacts.require("Report");
var ContentsManager = artifacts.require("ContentsManager");
var FundManager = artifacts.require("FundManager");
var AccountManager = artifacts.require("AccountManager");
// var ApiContents = artifacts.require("ApiContents");
// var ApiReport = artifacts.require("ApiReport");
// var ApiFund = artifacts.require("ApiFund");

const BigNumber = web3.BigNumber;

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("Council", function (accounts) {
    const owner = accounts[0];
    const testUser = accounts[1];
    const member = accounts[2];
    const cd = accounts[3];

    const decimals = Math.pow(10, 18);
    const initialBalance = new BigNumber(1000000000 * decimals);

    const initialDeposit = new BigNumber(100 * decimals);
    const reportRegistrationFee = new BigNumber(50 * decimals);
    const fundAvailable = false;

    const cdRate = 15 * decimals;
    const depositRate = 3 * decimals;
    const userPaybackRate = 2 * decimals;
    const reportRewardRate = 10 * decimals;
    const marketerRate = 10 * decimals;

    const createPoolInterval = 86400;
    const airdropAmount = 1000 * decimals;

    const addressZero = "0x0000000000000000000000000000000000000000";

    let token;
    let council;
    let userPaybackPool;
    let depositPool;
    let distributor;
    let marketer;
    let report;
    let contentsManager;
    let fundManager;
    let accountManager;

    let toBigNumber = function bigNumberToPaddedBytes32(num) {
        var n = num.toString(16).replace(/^0x/, '');
        while (n.length < 64) {
            n = "0" + n;
        }
        return "0x" + n;
    }

    let toAddress = function bigNumberToPaddedBytes32(num) {
        var n = num.toString(16).replace(/^0x/, '');
        while (n.length < 40) {
            n = "0" + n;
        }
        return "0x" + n;
    }

    before("Deploy contract", async() => {
        token = await PXL.new({from: owner});
        council = await Council.new(token.address, {from: owner});
        userPaybackPool = await UserPaybackPool.new(council.address, createPoolInterval, {from: owner});
        depositPool = await DepositPool.new(council.address, {from: owner});
        distributor = await PxlDistributor.new(council.address, {from: owner});
        marketer = await Marketer.new({from: owner});
        report = await Report.new(council.address, {from: owner});
        contentsManager = await ContentsManager.new(council.address, {from: owner});
        fundManager = await FundManager.new(council.address, {from: owner});
        accountManager = await AccountManager.new(council.address, airdropAmount, {from: owner});
    });

    describe("Test council.", () => {
        it("Setup council value.", async () => {
            await council.initialValue(
                initialDeposit,
                reportRegistrationFee,
                fundAvailable
            ).should.be.fulfilled;

            await council.initialRate(
                cdRate,
                depositRate,
                userPaybackRate,
                reportRewardRate,
                marketerRate
            ).should.be.fulfilled;

            await council.initialPictionAddress(
                userPaybackPool.address,
                depositPool.address,
                distributor.address,
                marketer.address,
                report.address,
                cd
            ).should.be.fulfilled;

            await council.initialManagerAddress(
                contentsManager.address,
                fundManager.address,
                accountManager.address
            ).should.be.fulfilled;
        });

        it("Check council member.", async () => {
            const notMember = await council.isMember.call(member, {from:member});
            notMember.should.be.equal(false);

            await council.setMember(member, true);
            const getMember = await council.isMember.call(member, {from:member});
            getMember.should.be.equal(true);
        });

        it("Get piction config.", async () => {
            const config = await council.getPictionConfig.call({from:owner});

            const pxl = config[0];
            const pictionValue = config[1];
            const pictionRate = config[2];
            const pictionAddress = config[3];
            const managerAddress = config[4];
            const apiAddress = config[5];
            const fundAvailable = config[6];

            pxl.should.be.equal(token.address);

            pictionValue[0].should.be.bignumber.equal(initialDeposit);
            pictionValue[1].should.be.bignumber.equal(reportRegistrationFee);

            pictionRate[0].should.be.bignumber.equal(cdRate);
            pictionRate[1].should.be.bignumber.equal(depositRate);
            pictionRate[2].should.be.bignumber.equal(userPaybackRate);
            pictionRate[3].should.be.bignumber.equal(reportRewardRate);
            pictionRate[4].should.be.bignumber.equal(marketerRate);

            pictionAddress[0].should.be.equal(userPaybackPool.address);
            pictionAddress[1].should.be.equal(depositPool.address);
            pictionAddress[2].should.be.equal(distributor.address);
            pictionAddress[3].should.be.equal(marketer.address);
            pictionAddress[4].should.be.equal(report.address);
            pictionAddress[5].should.be.equal(cd);

            managerAddress[0].should.be.equal(contentsManager.address);
            managerAddress[1].should.be.equal(fundManager.address);
            managerAddress[2].should.be.equal(accountManager.address);

            //api 컨트랙트 개발 완료 후 추가 예정
            apiAddress[0].should.be.equal(addressZero);
            apiAddress[1].should.be.equal(addressZero);
            apiAddress[2].should.be.equal(addressZero);

            fundAvailable.should.be.equal(fundAvailable);
        });

        it("Check report process.", async () => {
            await council.reporterDeduction(testUser, {from:owner}).should.be.rejected;
            await council.reporterBlock(testUser, {from:owner}).should.be.rejected;
            await council.reportReword(1, contentsManager, testUser, true, {from:owner}).should.be.rejected;
        });
    });
});
