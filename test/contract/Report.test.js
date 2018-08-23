var PXL = artifacts.require("PXL");
var Council = artifacts.require("Council");
var RoleManager = artifacts.require("RoleManager");
var PxlDistributor = artifacts.require("PxlDistributor")
var ContentsManager = artifacts.require("ContentsManager");
var Content = artifacts.require("Content");
var DepositPool = artifacts.require("DepositPool");
var Report = artifacts.require("Report");
var FundManager = artifacts.require("FundManager");

const BigNumber = web3.BigNumber;

require("chai")
.use(require("chai-as-promised"))
.use(require("chai-bignumber")(BigNumber))
.should();

contract("Report", function (accounts) {

    const owner = accounts[0];
    const writer = accounts[1];
    const reporter = accounts[2];
    const another = accounts[3];

    const decimals = Math.pow(10, 18);
    const initialBalance = new BigNumber(100000000 * decimals);

    const initialDepositToken = new BigNumber(100 * decimals);

    const recordAa = '{"title": "권짱님의 스트레스!!","genres": "액션, 판타지","synopsis": "요괴가 지니고 있는 능력으로 합법적 무력을 행사하고 사회적 문제를 해결하는 단체, \'연옥학원\'. 빼앗긴 심장과 기억을 되찾기 위해 연옥학원에 들어간 좀비, 블루의 모험이 다시 시작된다! 더욱 파워풀한 액션으로 돌아온 연옥학원, 그 두 번째 이야기!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const marketerRate = 0.1 * decimals;

    const reportDetail = "신고합니다. 불건전 컨텐츠입니다.";

    let token;
    let council;
    let roleManager;
    let depositPool;
    let contentsManager;
    let report;
    let fundManager;

    let content

    before("Contract initial setup", async() => {
        token = await PXL.new({from: owner});
        council = await Council.new(token.address, {from: owner});
        roleManager = await RoleManager.new({from: owner});
        depositPool = await DepositPool.new(council.address, {from: owner});
        contentsManager = await ContentsManager.new(council.address, {from: owner});
        report = await Report.new(council.address, {from: owner});
        fundManager = await FundManager.new(council.address, {from: owner});

        await council.initialValue(initialDepositToken, initialDepositToken, {from: owner}).should.be.fulfilled;
        await council.setRoleManager(roleManager.address, {from: owner}).should.be.fulfilled;
        await council.setReport(report.address, {from: owner}).should.be.fulfilled;
        await council.setDepositPool(depositPool.address, {from: owner}).should.be.fulfilled;
        await council.setReportRewardRate(0.5 * decimals, {from: owner}).should.be.fulfilled;
        await council.setFundManager(fundManager.address, {from: owner}).should.be.fulfilled;

        token.mint(initialBalance, {from: owner}).should.be.fulfilled;
        token.unlock({from: owner}).should.be.fulfilled;

        token.transfer(writer, 10000 * decimals, {from: owner}).should.be.fulfilled;
        token.transfer(reporter, 10000 * decimals, {from: owner}).should.be.fulfilled;
    });

    describe("Add contents", () => {
        it("send initial deposit", async () => {


            await token.approveAndCall(
                contentsManager.address,
                initialDepositToken,
                "0x0",
                {from: writer}
            ).should.be.fulfilled;
        });

        it("Check writer initial deposit.", async () => {
            const result = await contentsManager.getInitialDeposit.call(writer, {from: writer});
            const contractAmount = await token.balanceOf.call(contentsManager.address, {from: owner});
            result.should.be.bignumber.equal(initialDepositToken);
            contractAmount.should.be.bignumber.equal(initialDepositToken);
        });

        it("Create new contents", async () => {
            let tokenAmount = await token.balanceOf.call(contentsManager.address, {from: owner});
            tokenAmount.should.be.bignumber.equal(initialDepositToken);

            await contentsManager.addContents(
                recordAa,
                marketerRate,
                {from: writer}
            ).should.be.fulfilled;

            const writerContents = await contentsManager.getWriterContentsAddress.call(writer, {from: writer});
            const writerLength = writerContents[0].length;
            writerLength.should.be.bignumber.equal(1);
            content = writerContents[0][0];

            const resultAmount = await token.balanceOf.call(contentsManager.address, {from: owner});
            resultAmount.should.be.bignumber.equal(0);

            const depositPoolBalance = await token.balanceOf.call(depositPool.address, {from: owner});
            depositPoolBalance.should.be.bignumber.equal(initialDepositToken);
        });

    });

    describe("report", () => {
        it("send regFee reporter", async () => {
            await token.approveAndCall(
                report.address,
                initialDepositToken,
                "0x0",
                {from: reporter}
            ).should.be.fulfilled;
        });

        it("check reporter regFee", async () => {
            const result = await report.getRegFee.call({from: reporter});
            result[0].should.be.bignumber.equal(initialDepositToken);

            const contractAmount = await token.balanceOf.call(report.address, {from: owner});
            contractAmount.should.be.bignumber.equal(initialDepositToken);

            await report.returnRegFee({from: reporter}).should.be.rejected;
        });

        it("send report", async () => {
            await report.sendReport(content, reportDetail, {from: reporter}).should.be.fulfilled;
            await report.sendReport(content, reportDetail, {from: another}).should.be.rejected;
        });

        it("check report", async () => {
            const resultLength = await report.getReportsLength.call();
            resultLength.should.be.bignumber.equal(1);

            const resultCount = await report.getReportCount.call(content);
            resultCount.should.be.bignumber.equal(1);

            const resultReport = await report.getReport.call(0);
            resultReport[0].should.be.equal(content);
            resultReport[1].should.be.equal(reporter);
            resultReport[2].should.be.equal(reportDetail);
            resultReport[3].should.be.equal(false);
        });
    });

    describe("judge", () => {
        it("judge now", async () => {
            await council.judge(0, content, reporter, 0.1 * decimals, {from: owner}).should.be.fulfilled;
        });

        it("check judge and deduction", async () => {
            const result = await report.getRegFee.call({from: reporter});
            let value = initialDepositToken * 0.1;
            result[0].should.be.bignumber.equal(initialDepositToken - value);

            const contractAmount = await token.balanceOf.call(report.address, {from: owner});
            contractAmount.should.be.bignumber.equal(initialDepositToken - value);

            const resultReport = await report.getReport.call(0);
            resultReport[0].should.be.equal(content);
            resultReport[1].should.be.equal(reporter);
            resultReport[2].should.be.equal(reportDetail);
            resultReport[3].should.be.equal(true);
        });
    });

    describe("second report", () => {
        it("send second report", async () => {
            await report.sendReport(content, reportDetail, {from: reporter}).should.be.fulfilled;
        });

        it("check second report", async () => {
            const resultLength = await report.getReportsLength.call();
            resultLength.should.be.bignumber.equal(2);

            const resultCount = await report.getReportCount.call(content);
            resultCount.should.be.bignumber.equal(2);

            const resultReportCount = await report.getUncompletedReport.call(content);
            resultReportCount.should.be.bignumber.equal(1);

            const resultReport = await report.getReport.call(1);
            resultReport[0].should.be.equal(content);
            resultReport[1].should.be.equal(reporter);
            resultReport[2].should.be.equal(reportDetail);
            resultReport[3].should.be.equal(false);
        });
    });

    describe("second judge reward", () => {
        it("second judge now", async () => {
            const fromReporterBalance = await token.balanceOf.call(reporter, {from: owner});
            const fromDopositBalance = await depositPool.getDeposit.call(content);

            await council.judge(1, content, reporter, 0, {from: owner}).should.be.fulfilled;

            const afterReporterBalance = await token.balanceOf.call(reporter, {from: owner});
            const afterDopositBalance = await depositPool.getDeposit.call(content);

            const rate = await council.getReportRewardRate.call();
            const value = fromDopositBalance * (rate/decimals);

            afterReporterBalance.should.be.bignumber.equal(fromReporterBalance.toNumber() + value);
            afterDopositBalance.should.be.bignumber.equal(fromDopositBalance.toNumber() - value);
        });

        it("check second judge", async () => {
            const resultReport = await report.getReport.call(1);
            resultReport[0].should.be.equal(content);
            resultReport[1].should.be.equal(reporter);
            resultReport[2].should.be.equal(reportDetail);
            resultReport[3].should.be.equal(true);
        });
    });

    describe("third report", () => {
        it("send third report", async () => {
            await report.sendReport(content, reportDetail, {from: reporter}).should.be.fulfilled;
        });

        it("check third report", async () => {
            const resultLength = await report.getReportsLength.call();
            resultLength.should.be.bignumber.equal(3);

            const resultCount = await report.getReportCount.call(content);
            resultCount.should.be.bignumber.equal(3);

            const resultReportCount = await report.getUncompletedReport.call(content);
            resultReportCount.should.be.bignumber.equal(1);

            const resultReport = await report.getReport.call(2);
            resultReport[0].should.be.equal(content);
            resultReport[1].should.be.equal(reporter);
            resultReport[2].should.be.equal(reportDetail);
            resultReport[3].should.be.equal(false);
        });
    });

    describe("third judge and deduction and block", () => {
        it("third judge now", async () => {
            const fromResult = await report.getRegFee.call({from: reporter});
            await council.judge(2, content, reporter, 0.6 * decimals, {from: owner}).should.be.fulfilled;
            const afterResult = await report.getRegFee.call({from: reporter});
            let value = fromResult[0] * 0.6;

            afterResult[0].should.be.bignumber.equal(fromResult[0].toNumber() - value);
        });

        it("check third judge", async () => {
            const resultReport = await report.getReport.call(2);
            resultReport[0].should.be.equal(content);
            resultReport[1].should.be.equal(reporter);
            resultReport[2].should.be.equal(reportDetail);
            resultReport[3].should.be.equal(true);
        });

        it("check block", async () => {
            await report.sendReport(content, reportDetail, {from: reporter}).should.be.rejected;
        });

        it("check block release", async () => {
            const blockReleasePromise = new Promise( async (resolve, reject) => {
                setTimeout( async() => {
                    await report.sendReport(content, reportDetail, {from: reporter}).should.be.fulfilled;
                    resolve();
                }, 12000);
            });
            await blockReleasePromise;
        });
    });

    describe("check ending", () => {
        it("check deposit return rejected", async () => {
            await depositPool.release(content).should.be.rejected;
        });

        it("check reportRegFee return rejected", async () => {
            await report.returnRegFee({from: reporter}).should.be.rejected;
        });

        it("ending judge now", async () => {
            const fromResult = await report.getRegFee.call({from: reporter});
            await council.judge(3, content, reporter, 0.1 * decimals, {from: owner}).should.be.fulfilled;
            const afterResult = await report.getRegFee.call({from: reporter});
            let value = fromResult[0] * 0.1;

            afterResult[0].should.be.bignumber.equal(fromResult[0].toNumber() - value);
        });

        it("check deposit return", async () => {
            await depositPool.release(content, {from: writer}).should.be.fulfilled;
        });

        it("check reportRegFee return", async () => {
            await report.returnRegFee({from: reporter}).should.be.fulfilled;

            let amount = await report.getRegFee.call({from: reporter});
            amount[0].should.be.bignumber.equal(0);
        });
    });
});
