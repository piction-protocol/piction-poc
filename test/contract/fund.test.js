const { timer } = require("../helpers/timer");
const { forEachAsync } = require("../helpers/forEachAsync");

const Pxl = artifacts.require("PXL");
const FundManager = artifacts.require("FundManager");
const Fund = artifacts.require("Fund")
const Content = artifacts.require("Content");
const RoleManager = artifacts.require("RoleManager");
const Council = artifacts.require("Council");
const SupporterPool = artifacts.require("SupporterPool");

const BigNumber = web3.BigNumber;

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("Fund", function (accounts) {
    const owner = accounts[0];
    const pxlDistributor = accounts[1];
    const writer = accounts[2];
    const users = accounts.slice(3, 5);
    const deploy = accounts[7];

    const decimals = Math.pow(10, 18);
    const initialBalance = new BigNumber(100000 * decimals);
    const initialUserBalance = new BigNumber(100 * decimals);

    let token;
    let council;
    let roleManager;
    let content;
    let fundAddresses;
    let fundManager;

    const record = '{"title": "철수님의 잡학사전!!","genres": "액션, 판타지","synopsis": "요괴가 지니고 있는 능력으로 합법적 무력을 행사하고 사회적 문제를 해결하는 단체, \'연옥학원\'. 빼앗긴 심장과 기억을 되찾기 위해 연옥학원에 들어간 좀비, 블루의 모험이 다시 시작된다! 더욱 파워풀한 액션으로 돌아온 연옥학원, 그 두 번째 이야기!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const marketerRate = 10;

    before("Setup contract", async () => {
        token = await Pxl.new({from: deploy});
        council = await Council.new(token.address, {from: owner});
        roleManager = await RoleManager.new({from: owner});

        await council.setRoleManager(roleManager.address, {from: owner});
        content = await Content.new(record, writer, marketerRate, roleManager.address);

        await token.transferOwnership(owner, {from: deploy}).should.be.fulfilled;
        await token.mint(initialBalance, {from: owner}).should.be.fulfilled;

        await token.unlock({from: owner});

        await token.transfer(writer, initialUserBalance, {from: owner});

        await forEachAsync(users, async (user) => {
            await token.transfer(user, initialUserBalance, {from: owner});
        });

        const startTime = Date.now() + 500;
        const endTime = startTime + 2500;
        const poolSize = 5;
        const releaseInterval = 2000;
        const distributationRate = 10 * decimals;
        const detail = "1234";

        fundManager = await FundManager.new(council.address, {from: owner});

        await fundManager.addFund(
            content.address,
            writer,
            startTime,
            endTime,
            poolSize,
            releaseInterval,
            distributationRate,
            detail, {from: owner}).should.be.fulfilled;

        fundAddresses = await fundManager.getFunds.call(content.address);
    });

    describe("Funding", () => {
        it("one user supports.", async () => {
            const supportAmount = new BigNumber(2 * decimals);
            const supporter = users[0];
            const fund = await Fund.at(fundAddresses[0]);

            const beforeSupporterBalance = await token.balanceOf(supporter);
            const beforeFundBalance = await token.balanceOf(fund.address);

            await timer(1500);

            await token.approveAndCall(fund.address, supportAmount, "", {from: supporter});

            const afterSupporterBalance = await token.balanceOf(supporter);
            const afterFundBalance = await token.balanceOf(fund.address);

            beforeSupporterBalance.sub(afterSupporterBalance).should.be.bignumber.equal(supportAmount);
            afterFundBalance.should.be.bignumber.equal(supportAmount);

            const supportInfo = await fund.getSupporters();

            supportInfo[0][0].should.be.equal(supporter);
            supportInfo[1][0].should.be.bignumber.equal(supportAmount);
        });

        it("several users supports.", async () => {
            const supportAmount = new BigNumber(2 * decimals);
            const supporters = users;
            const fund = await Fund.at(fundAddresses[0]);

            await timer(1000);

            await forEachAsync(supporters, async (supporter) => {
                await token.approveAndCall(fund.address, supportAmount, "", {from: supporter});
            });

            const supportInfo = await fund.getSupporters();

            await forEachAsync(supportInfo[0], async (info, i) => {
                const supporter = supportInfo[0][i];
                const investment = supportInfo[1][i];

                supporter.should.be.equal(supporters[i]);
                investment.should.be.bignumber.equal(supportAmount);
            });
        });

        it("supports to next fund.", async () => {
            const supportAmount = new BigNumber(4 * decimals);
            const supporter = users[0];

            await timer(3000);

            const startTime = Date.now() + 500;
            const endTime = startTime + 2000;
            const poolSize = 5;
            const releaseInterval = 2000;
            const distributationRate = 10 * decimals;
            const detail = "1234";

            await fundManager.addFund(
                content.address,
                writer,
                startTime,
                endTime,
                poolSize,
                releaseInterval,
                distributationRate,
                detail, {from: owner}).should.be.fulfilled;

            fundAddresses = await fundManager.getFunds.call(content.address);

            const lastIndex = fundAddresses.length - 1;

            const fundAddress = fundAddresses[lastIndex];
            const fund = await Fund.at(fundAddress);

            await timer(1500);
            await token.approveAndCall(fund.address, supportAmount, "", {from: supporter});

            const supportInfo = await fund.getSupporters();

            supportInfo[0][0].should.be.equal(supporter);
            supportInfo[1][0].should.be.bignumber.equal(supportAmount);
        });
    });

    describe("Vote", () => {
        before("create supporter pool", async () => {
            await timer(3000);

            await forEachAsync(fundAddresses, async (address) => {
                const fund = await Fund.at(address);
                await fund.createSupporterPool();
            });
        });

        it ("voting on first fund", async () => {
            const fund = await Fund.at(fundAddresses[0]);
            const supporter = users[0];

            const supporterPoolAddress = await fund.supporterPool.call();
            const supporterPool = await SupporterPool.at(supporterPoolAddress)

            const beforeDistributions = await supporterPool.getDistributions();

            await supporterPool.vote(0, {from: supporter});

            const afterDistributions = await supporterPool.getDistributions();
            afterDistributions[0].should.have.length(beforeDistributions[0].length + 1);

            const isVoting = await supporterPool.isVoting(0, {from: supporter});
            isVoting.should.be.equal(true);
        });
    });

    describe("Distribution", () => {
        it("delay distribution by voting result", async () => {
            const fund = await Fund.at(fundAddresses[0]);
            const supporterPoolAddress = await fund.supporterPool.call();
            const supporterPool = await SupporterPool.at(supporterPoolAddress)

            const beforeWriterBalance = await token.balanceOf(writer);

            await timer(1000);
            await supporterPool.distribution();

            const afterWriterBalance = await token.balanceOf(writer);

            beforeWriterBalance.should.be.bignumber.equal(afterWriterBalance);
        });

        it("distribution to content provider", async () => {
            const supportAmount = new BigNumber(4 * decimals);
            const poolSize = 5;
            const distributionAmount = supportAmount / poolSize;
            const lastIndex = fundAddresses.length - 1;
            const fundAddress = fundAddresses[lastIndex];
            const fund = await Fund.at(fundAddress);
            const supporterPoolAddress = await fund.supporterPool.call();
            const supporterPool = SupporterPool.at(supporterPoolAddress);

            const beforeWriterBalance = await token.balanceOf(writer);

            await timer(1000);
            await supporterPool.distribution();

            const afterWriterBalance = await token.balanceOf(writer);

            afterWriterBalance.sub(beforeWriterBalance).should.be.bignumber.equal(distributionAmount);
        })
    });
});
