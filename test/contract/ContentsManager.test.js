var PXL = artifacts.require("PXL");
var Council = artifacts.require("Council");
var RoleManager = artifacts.require("RoleManager");
var ContentsManager = artifacts.require("ContentsManager");
var Content = artifacts.require("Content");
var DepositPool = artifacts.require("DepositPool");

const BigNumber = web3.BigNumber;

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("ContentsManager", function (accounts) {
    const owner = accounts[0];
    const writerA = accounts[1];
    const writerB = accounts[2];
    const writerC = accounts[3];
    const deploy = accounts[4];

    const decimals = Math.pow(10, 18);
    const initialBalance = new BigNumber(1000000000 * decimals);

    const initialDepositToken = new BigNumber(100 * decimals);
    const marketerRate = 10;

    const recordAa = '{"title": "권짱님의 스트레스!!","genres": "액션, 판타지","synopsis": "요괴가 지니고 있는 능력으로 합법적 무력을 행사하고 사회적 문제를 해결하는 단체, \'연옥학원\'. 빼앗긴 심장과 기억을 되찾기 위해 연옥학원에 들어간 좀비, 블루의 모험이 다시 시작된다! 더욱 파워풀한 액션으로 돌아온 연옥학원, 그 두 번째 이야기!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const recordAb = '{"title": "님명님의 검은사막~~~","genres": "판타지, 성인","synopsis": "매달리던 알바도 짤리고 직업도 없는 채 나이만 먹은 채 30. 이런 나에게 어느 날, 어플 하나로 부자가 될 기회가 찾아왔다. 슈퍼카 건물주 여자 모든 것을 내손에 넣을 수 있다고?","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const recordBa = '{"title": "호롤로로로로님의 게임시간!@#%!","genres": "게임, 일상","synopsis": "여기 이 남자를 보시라! 뭘 해도 어그로 가 끌리는 미친 존재감! 낙천적이며 교활하기 까지한 티이모 유저 제인유와 그의 친구들의 좌충우돌 스토리!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const recordCa = '{"title": "에러가 나는 상황!@!@$","genres": "게임, 일상","synopsis": "여기 이 남자를 보시라! 뭘 해도 어그로 가 끌리는 미친 존재감! 낙천적이며 교활하기 까지한 티이모 유저 제인유와 그의 친구들의 좌충우돌 스토리!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';


    let token;
    let council;
    let roleManager;
    let depositPool;
    let contentsManager;
    let content;

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

    before("Contract initial setup", async() => {
        token = await PXL.new({from: deploy});
        council = await Council.new(token.address, {from: owner});
        roleManager = await RoleManager.new({from: owner});
        depositPool = await DepositPool.new(council.address, {from: owner});
        contentsManager = await ContentsManager.new(council.address, {from: owner});

        await council.initialValue(initialDepositToken, initialDepositToken, {from: owner}).should.be.fulfilled;
        await council.setRoleManager(roleManager.address, {from: owner}).should.be.fulfilled;
        await council.setDepositPool(depositPool.address, {from: owner}).should.be.fulfilled;

        await token.transferOwnership(owner, {from: deploy}).should.be.fulfilled;
        await token.mint(initialBalance, {from: owner}).should.be.fulfilled;
        await token.unlock({from: owner}).should.be.fulfilled;
        await token.transfer(writerA, 1000 * decimals, {from: owner}).should.be.fulfilled;
        await token.transfer(writerB, 500 * decimals, {from: owner}).should.be.fulfilled;
        await token.transfer(writerC, 7000 * decimals, {from: owner}).should.be.fulfilled;

    });

    describe("Add contents", () => {
        before("send initial deposit", async () => {
            await token.approveAndCall(
                contentsManager.address,
                initialDepositToken,
                "",
                {from: writerA}
            ).should.be.fulfilled;

            await token.approveAndCall(
                contentsManager.address,
                initialDepositToken,
                "",
                {from: writerB}
            ).should.be.fulfilled;

        });

        it("Check writer initial deposit.", async () => {
            const resultA = await contentsManager.getInitialDeposit.call(writerA, {from: writerA});
            const resultB = await contentsManager.getInitialDeposit.call(writerB, {from: writerB});
            const contractAmount = await token.balanceOf.call(contentsManager.address, {from: owner});

            resultA.should.be.bignumber.equal(initialDepositToken);
            resultB.should.be.bignumber.equal(initialDepositToken);
            contractAmount.should.be.bignumber.equal(initialDepositToken * 2);
        });

        it("Create new contents", async () => {
            let tokenAmount = await token.balanceOf.call(contentsManager.address, {from: owner});
            let compareAmount = tokenAmount - (initialDepositToken * 2);

            await contentsManager.addContents(
                recordAa,
                marketerRate,
                {from: writerA}
            ).should.be.fulfilled;

            await contentsManager.addContents(
                recordBa,
                marketerRate,
                {from: writerB}
            ).should.be.fulfilled;

            const resultAmount = await token.balanceOf.call(contentsManager.address, {from: owner});

            const writerAContents = await contentsManager.getWriterContentsAddress.call(writerA, {from: writerA});
            const writerBContents = await contentsManager.getWriterContentsAddress.call(writerB, {from: writerB});

            const writerALength = writerAContents[0].length;
            const writerBLength = writerBContents[0].length;

            resultAmount.should.be.bignumber.equal(compareAmount);
            writerALength.should.be.bignumber.equal(1);
            writerBLength.should.be.bignumber.equal(1);
        });

        it("Initial Deposit not confirm", async () => {
            await contentsManager.addContents(
                recordCa,
                marketerRate,
                {from: writerC}
            ).should.be.rejected;

            const writerCContents = await contentsManager.getWriterContentsAddress.call(writerC, {from: writerC});
            const writerCLength = writerCContents[0].length;
            const writerCResult = writerCContents[1];

            writerCLength.should.be.bignumber.equal(0);
            writerCResult.should.be.equal(false);
        });

        it("Check total contents count", async () =>{
            const contents = await contentsManager.getContents.call({from: owner});
            const totalCount = contents.length;

            totalCount.should.be.bignumber.equal(2);
        });

        it("Check depositpool token amount", async () => {
            const depositPoolBalance = await token.balanceOf.call(depositPool.address, {from: owner});

            depositPoolBalance.should.be.bignumber.equal(initialDepositToken * 2);
        });
    });
});
