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
var ApiContents = artifacts.require("ApiContents");

const BigNumber = web3.BigNumber;

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("AccountManager", function (accounts) {
    const owner = accounts[0];
    const writer = accounts[1];
    const buyer = accounts[2];
    const user = accounts[3];
    const denied = accounts[4];
    const cd = accounts[5];

    const decimals = Math.pow(10, 18);
    const initialBalance = new BigNumber(1000000000 * decimals);

    const initialDeposit = new BigNumber(100 * decimals);
    const reportRegistrationFee = new BigNumber(50 * decimals);
    const fundAvailable = false;

    const cdRate = 0.15 * decimals;
    const depositRate = 0.03 * decimals;
    const userPaybackRate = 0.02 * decimals;
    const reportRewardRate = 0.1 * decimals;
    const marketerRate = 0.1 * decimals;

    const createPoolInterval = 86400;
    const airdropAmount = 1000 * decimals;

    const addressZero = "0x0000000000000000000000000000000000000000";

    const record = '{"title": "권짱님의 스트레스!!","genres": "액션, 판타지","synopsis": "요괴가 지니고 있는 능력으로 합법적 무력을 행사하고 사회적 문제를 해결하는 단체, \'연옥학원\'. 빼앗긴 심장과 기억을 되찾기 위해 연옥학원에 들어간 좀비, 블루의 모험이 다시 시작된다! 더욱 파워풀한 액션으로 돌아온 연옥학원, 그 두 번째 이야기!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const updateRecord = '{"title": "권짱님의 업그레이드 스트레스!!","genres": "액션, 판타지","synopsis": "요괴가 지니고 있는 능력으로 합법적 무력을 행사하고 사회적 문제를 해결하는 단체, \'연옥학원\'. 빼앗긴 심장과 기억을 되찾기 위해 연옥학원에 들어간 좀비, 블루의 모험이 다시 시작된다! 더욱 파워풀한 액션으로 돌아온 연옥학원, 그 두 번째 이야기!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const episode = '{"title": "똥쟁이님의 신발 구매???????","genres": "일상","synopsis": "여기 이 남자를 보시라! 뭘 해도 어그로 가 끌리는 미친 존재감! 낙천적이며 교활하기 까지한 티이모 유저 제인유와 그의 친구들의 좌충우돌 스토리!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const imageUrl = '{"cuts": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg,https://www.battlecomics.co.kr/webtoons/467"}';

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
    let apiContents;
    let pxlDistributor;

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
        apiContents = await ApiContents.new(council.address, contentsManager.address, {from:owner});
        pxlDistributor = await PxlDistributor.new(council.address, {from:owner});

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
            pxlDistributor.address,
            marketer.address,
            report.address,
            cd
        ).should.be.fulfilled;

        await council.initialManagerAddress(
            contentsManager.address,
            fundManager.address,
            accountManager.address
        ).should.be.fulfilled;

        await council.initialApiAddress(
            apiContents.address,
            apiContents.address,
            apiContents.address
        ).should.be.fulfilled;

        await token.mint(initialBalance, {from:owner}).should.be.fulfilled;
        await token.unlock({from: owner}).should.be.fulfilled;
        await token.transfer(accountManager.address, 1000000 * decimals, {from: owner}).should.be.fulfilled;
    });

    describe("Test accountManager.", () => {
        it("Create new account.", async () => {
            let writerBalance = await token.balanceOf.call(writer, {from: writer});
            let buyerBalance = await token.balanceOf.call(buyer, {from: buyer});
            let userBalance = await token.balanceOf.call(user, {from: user});

            writerBalance.should.be.bignumber.equal(0);
            buyerBalance.should.be.bignumber.equal(0);
            userBalance.should.be.bignumber.equal(0);

            await accountManager.createNewAccount(
                "writer",
                "writer1234",
                "writer privateKey",
                writer,
                {from: writer}
            ).should.be.fulfilled;

            await accountManager.createNewAccount(
                "buyer",
                "buyer1234",
                "buyer privateKey",
                buyer,
                {from: buyer}
            ).should.be.fulfilled;

            await accountManager.createNewAccount(
                "user",
                "user1234",
                "user privateKey",
                user,
                {from: user}
            ).should.be.fulfilled;

            writerBalance = await token.balanceOf.call(writer, {from: writer});
            buyerBalance = await token.balanceOf.call(buyer, {from: buyer});
            userBalance = await token.balanceOf.call(user, {from: user});

            writerBalance.should.be.bignumber.equal(airdropAmount);
            buyerBalance.should.be.bignumber.equal(airdropAmount);
            userBalance.should.be.bignumber.equal(airdropAmount);

            let _isRegisterd = await accountManager.isRegistered.call("writer", {from:writer});
            _isRegisterd.should.be.equal(true);

            _isRegisterd = false;
            _isRegisterd = await accountManager.isRegistered.call("buyer", {from:buyer});
            _isRegisterd.should.be.equal(true);

            _isRegisterd = false;
            _isRegisterd = await accountManager.isRegistered.call("user", {from:user});
            _isRegisterd.should.be.equal(true);
        });

        it("Login test.", async () => {
            const _deniedResult = await accountManager.login.call("denied", "denied1234", {from:denied});
            _deniedResult[0].should.be.equal("Login failed: Please register account.");
            _deniedResult[1].should.be.equal(false);

            const _writerResult = await accountManager.login.call("writer", "writer1234", {from:writer});
            _writerResult[0].should.be.equal("writer privateKey");
            _writerResult[1].should.be.equal(true);

            const _buyerResult = await accountManager.login.call("buyer", "buyer1234", {from:buyer});
            _buyerResult[0].should.be.equal("buyer privateKey");
            _buyerResult[1].should.be.equal(true);

            const _userResult = await accountManager.login.call("user", "user1234", {from:user});
            _userResult[0].should.be.equal("user privateKey");
            _userResult[1].should.be.equal(true);
        });

        it("User Purchase history.", async () =>{
            const episodePrice = 10 * decimals;
            const _toAddress = await council.getContentsManager.call({from: writer});
            await token.approveAndCall(_toAddress, initialDeposit, "", {from: writer});

            const _initialDeposit = await apiContents.getInitialDeposit.call(writer, {from: writer});
            _initialDeposit.should.be.bignumber.equal(initialDeposit);

            await apiContents.addContents(record, marketerRate, {from: writer});
            const _contentsAddressInfo = await apiContents.getWriterContentsAddress.call(writer, {from:writer});
            _contentsAddressInfo.length.should.be.equal(1);

            const _contentsAddress = _contentsAddressInfo[0];
            await apiContents.addEpisode(_contentsAddress, episode, imageUrl, episodePrice, {from:writer});

            let _episodeInfo = await apiContents.getEpisodeFullList.call(_contentsAddress, {from:buyer});
            let _episodeRecord = _episodeInfo[0];
            let _episodePrice = _episodeInfo[1][0];
            let _episodeBuyCount = _episodeInfo[2][0];
            let _episodeIsPurchased = _episodeInfo[3][0];

            _episodeBuyCount.toNumber().should.be.equal(0);
            _episodePrice.should.be.bignumber.equal(episodePrice);
            _episodeIsPurchased.should.be.equal(false);

            await token.approveAndCall(
                pxlDistributor.address,
                episodePrice,
                _contentsAddress + user.substr(2) + toBigNumber(0).substring(2),
                {from: buyer}
            );

            const cdBalance = await token.balanceOf.call(cd, {from:cd});
            cdBalance.should.be.bignumber.equal(1.5 * decimals);

            _episodeInfo = await apiContents.getEpisodeFullList.call(_contentsAddress, {from:buyer});
            _episodeBuyCount = _episodeInfo[2][0];
            _episodeIsPurchased = _episodeInfo[3][0];

            _episodeBuyCount.toNumber().should.be.equal(1);
            _episodeIsPurchased.should.be.equal(true);

            const _purchaseContentsAddress = await accountManager.getPurcahsedContents({from:buyer});
            _purchaseContentsAddress.length.should.be.equal(1);
            _purchaseContentsAddress[0].should.be.equal(_contentsAddress);

            const _purchaseContentEpisodes = await accountManager.getPurchasedContentEpisodes(_contentsAddress, {from: buyer});
            _purchaseContentEpisodes[0].should.be.equal(_contentsAddress);
            _purchaseContentEpisodes[1].length.should.be.equal(1);
            _purchaseContentEpisodes[2][0].should.be.equal(true);
        });
    });
});
