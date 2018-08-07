var PXL = artifacts.require("PXL");
var Council = artifacts.require("Council");
var UserPaybackPool = artifacts.require("UserPaybackPool");
var DepositPool = artifacts.require("DepositPool");
var RoleManager = artifacts.require("RoleManager");
var ContentsManager = artifacts.require("ContentsManager");
var Content = artifacts.require("Content");
var FundManager = artifacts.require("FundManager");
var Fund = artifacts.require("Fund");
var PxlDistributor = artifacts.require("PxlDistributor");
var Marketer = artifacts.require("Marketer");
var Report = artifacts.require("Report");

const BigNumber = web3.BigNumber;

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("PxlDistributor", function (accounts) {
    const owner = accounts[0];
    const writer = accounts[1];
    const cd = accounts[2];
    const marketer1 = accounts[3];
    const marketer2 = accounts[4];
    const supporter = accounts[5];
    const user = accounts[6];
    const user2 = accounts[7];
    const supporter2 = accounts[8];
    const supporter3 = accounts[9];
    const freeUser = accounts[10];

    const decimals = Math.pow(10, 18);
    const initialBalance = new BigNumber(1000000000 * decimals);

    const initialDeposit = new BigNumber(100 * decimals);
    const reportRegistrationFee = new BigNumber(10 * decimals);
    const cdRate = 0.15 * decimals;
    const depositRate = 0.03 * decimals;
    const userPaybackRate = 0.02 * decimals;
    const reportRewardRate = 0.01 * decimals;
    const marketerDefaultRate = 0.15 * decimals;

    const userPaybackPoolInterval = 86400;

    const contentRecord = '{"title": "권짱님의 스트레스!!","genres": "액션, 판타지","synopsis": "요괴가 지니고 있는 능력으로 합법적 무력을 행사하고 사회적 문제를 해결하는 단체, \'연옥학원\'. 빼앗긴 심장과 기억을 되찾기 위해 연옥학원에 들어간 좀비, 블루의 모험이 다시 시작된다! 더욱 파워풀한 액션으로 돌아온 연옥학원, 그 두 번째 이야기!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const episodeRecord = '{"title": "똥쟁이님의 신발 구매???????","genres": "일상","synopsis": "여기 이 남자를 보시라! 뭘 해도 어그로 가 끌리는 미친 존재감! 낙천적이며 교활하기 까지한 티이모 유저 제인유와 그의 친구들의 좌충우돌 스토리!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';

    const episodePrice = new BigNumber(10 * decimals);

    let token;
    let council;
    let userPayback;
    let deposit;
    let roleManager;
    let contentsManager;
    let content;
    let fundManager;
    let fund;
    let distributor;
    let marketers;
    let reporter;


    before("Initial setup", async() => {
        //===========================    컨트랙트 배포 시작    ===========================
        token = await PXL.new(initialBalance, {from: owner});
        council = await Council.new(token.address, {from: owner});
        userPayback = await UserPaybackPool.new(council.address, userPaybackPoolInterval, {from: owner});
        deposit = await DepositPool.new(council.address, {from: owner});
        roleManager = await RoleManager.new({from: owner});
        contentsManager = await ContentsManager.new(council.address, {from: owner});
        fundManager = await FundManager.new(council.address, {from: owner});
        distributor = await PxlDistributor.new(council.address, {from: owner});
        marketers = await Marketer.new({from: owner});
        reporter = await Report.new(council.address, {from: owner});
        //===========================    컨트랙트 배포 종료   ===========================


        //===========================    위원회 초기 값 설정 시작    ===========================
        await council.initialValue(
            initialDeposit,
            reportRegistrationFee,
            {from: owner}
        );

        await council.initialRate(
            cdRate,
            depositRate,
            userPaybackRate,
            reportRewardRate,
            marketerDefaultRate,
            {from: owner}
        );

        await council.initialPictionAddress(
            userPayback.address,
            deposit.address,
            distributor.address,
            marketers.address,
            reporter.address,
            {from: owner}
        ).should.be.fulfilled;

        await council.initialManagerAddress(
            roleManager.address,
            contentsManager.address,
            fundManager.address,
            {from: owner}
        ).should.be.fulfilled;
        //===========================    위원회 초기 값 설정 종료    ===========================


        //===========================    PxlDistributor 권한 등록 시작    ===========================
        await roleManager.addAddressToRole(distributor.address, "PXL_DISTRIBUTOR", {from: owner});
        //===========================    PxlDistributor 권한 등록 시작    ===========================


        //===========================    토큰 전송 시작    ===========================
        token.unlock({from: owner}).should.be.fulfilled;

        token.transfer(writer, 100 * decimals, {from: owner}).should.be.fulfilled;
        token.transfer(supporter, 500 * decimals, {from: owner}).should.be.fulfilled;
        token.transfer(user, 1000 * decimals, {from: owner}).should.be.fulfilled;
        token.transfer(user2, 1000 * decimals, {from: owner}).should.be.fulfilled;
        token.transfer(supporter2, 500 * decimals, {from: owner}).should.be.fulfilled;
        token.transfer(supporter3, 300 * decimals, {from: owner}).should.be.fulfilled;
        //===========================    토큰 전송 시작    ===========================
    });

    describe("PXL distribution", async() => {
        before("contents & fund", async () => {
            const marketerRate = 0.1 * decimals;;

            //===========================    콘텐츠 생성 시작    ===========================
            await token.approveAndCall(
                contentsManager.address,
                initialDeposit,
                "",
                {from: writer}
            ).should.be.fulfilled;

            await contentsManager.addContents(
                contentRecord,
                marketerRate,
                {from: writer}
            ).should.be.fulfilled;

            const writerContents = await contentsManager.getWriterContentsAddress.call(writer, {from: writer});
            content = Content.at(writerContents[0][0]);

            const writerContentAddress = writerContents[0].length;
            const result = writerContents[1];

            const rate = await content.getMarketerRate.call({from: writer});

            writerContentAddress.should.be.bignumber.equal(1);
            result.should.be.equal(true);
            rate.should.be.bignumber.equal(marketerRate);
            //===========================    콘텐츠 생성 종료    ===========================

            //===========================    펀드 생성 시작    ===========================
            const startTime = Date.now() + 3000;    // 현재시간 +5초

            await fundManager.addFund(
                content.address,
                writer,
                startTime,
                startTime + 10000,
                1,
                600,
                5 * decimals,
                "권짱의 스트레스에 투자하라!!!",
                {from: writer}
            );

            const fundAddress = await fundManager.getFunds.call(content.address, {from: writer});
            const fundLength = fundAddress.length;

            fundLength.should.be.equal(1);

            fund = Fund.at(fundAddress[0]);

            const supportTokenPromise = new Promise( async (resolve, reject) => {
                setTimeout( async() => {
                    await token.approveAndCall(
                        fund.address,
                        500 * decimals,
                        "",
                        {from: supporter}
                    );

                    await token.approveAndCall(
                        fund.address,
                        500 * decimals,
                        "",
                        {from: supporter2}
                    );

                    await token.approveAndCall(
                        fund.address,
                        300 * decimals,
                        "",
                        {from: supporter3}
                    );
                    resolve();
                }, 5000);
            });
            await supportTokenPromise;

            const startPromise = new Promise( async (resolve, reject) => {
                setTimeout( async() => {
                    await fund.createSupporterPool({from: writer});
                    resolve();
                }, 15000);
            });
            await startPromise;
            //===========================    펀드 생성 종료    ===========================


            //===========================    에피소드 생성 시작    ===========================
            await content.addEpisode(
                episodeRecord,
                episodePrice,
                {from: writer}
            );

            const episodeLength = await content.getEpisodeLength.call({from: writer});
            const episodeDetail = await content.getEpisodeDetail.call(0, {from: writer});

            episodeLength.should.be.bignumber.equal(1);
            episodeDetail[0].should.be.equal(episodeRecord);
            episodeDetail[1].should.be.bignumber.equal(episodePrice);
            episodeDetail[2].should.be.bignumber.equal(0);

            await content.addEpisode(
                episodeRecord,
                0,
                {from: writer}
            );

            const episodeLength1 = await content.getEpisodeLength.call({from: writer});
            const episodeDetail1 = await content.getEpisodeDetail.call(1, {from: writer});

            episodeLength1.should.be.bignumber.equal(2);
            episodeDetail1[0].should.be.equal(episodeRecord);
            episodeDetail1[1].should.be.bignumber.equal(0);
            episodeDetail1[2].should.be.bignumber.equal(0);
            //===========================    에피소드 생성 종료    ===========================
        });

        it("purchase episode", async() => {
            const marketerRate = 0.1 * decimals;;

            const marketerKey = await marketers.generateMarketerKey.call({from:marketer1});
            await marketers.setMarketerKey(String(marketerKey), {from: marketer1});
            const marketerAddress = await marketers.getMarketerAddress(marketerKey, {from: marketer1});

            const tempJson = {
                "cdAddress": String(cd),
                "contentAddress": String(content.address),
                "episodeIndex": 0,
                "marketer": String(marketerAddress)
            };
            const purchaseJson = JSON.stringify(tempJson);

            const userAmount = await token.balanceOf.call(user, {from: owner});

            await token.approveAndCall(
                distributor.address,
                episodePrice,
                purchaseJson,
                {from: user}
            );

            const cdRate = await council.getCdRate();
            const depositRate = await council.getDepositRate();
            const userPaybackRate = await council.getUserPaybackRate();

            const cdAmount = await token.balanceOf.call(cd, {from: owner});
            const marketerAmount = await token.balanceOf.call(marketer1, {from: owner});
            const supporterAmount = await token.balanceOf.call(supporter, {from: owner});
            const supporter2Amount = await token.balanceOf.call(supporter2, {from: owner});
            const supporter3Amount = await token.balanceOf.call(supporter3, {from: owner});
            const depositAmount = await token.balanceOf.call(deposit.address, {from: owner});
            const writerAmount = await token.balanceOf.call(writer, {from: owner});
            const distributorAmount = await token.balanceOf.call(distributor.address, {from: owner});
            const userpaybackAmount = await token.balanceOf.call(userPayback.address, {from: owner});

            console.log(supporterAmount.toNumber() / decimals);
            console.log(supporter2Amount.toNumber() / decimals);
            console.log(supporter3Amount.toNumber() / decimals);
            console.log(writerAmount.toNumber() / decimals);
            console.log(cdAmount.toNumber() / decimals);
            console.log(marketerAmount.toNumber() / decimals);
            console.log(depositAmount.toNumber() / decimals);
            console.log(userpaybackAmount.toNumber() / decimals);
            console.log(distributorAmount.toNumber() / decimals);

            const resultAmount = (supporterAmount.toNumber() / decimals) + (supporter2Amount.toNumber() / decimals)
            +(supporter3Amount.toNumber() / decimals)+(writerAmount.toNumber() / decimals)+(cdAmount.toNumber() / decimals)
            +(marketerAmount.toNumber() / decimals)+(depositAmount.toNumber() / decimals) - (initialDeposit / decimals)
            +(userpaybackAmount.toNumber() / decimals);

            console.log(resultAmount);

            //마케터 주소 확인
            marketerAddress.should.be.equal(marketer1);

            // 분배 된 pixel 양 확인
            distributorAmount.should.be.bignumber.equal(0);
            //writerAmount.should.be.bignumber.equal(0);
            cdAmount.should.be.bignumber.equal(episodePrice * cdRate / decimals);
            marketerAmount.should.be.bignumber.equal(episodePrice * marketerRate / decimals);
            userpaybackAmount.should.be.bignumber.equal(episodePrice * userPaybackRate / decimals);
            supporterAmount.should.be.bignumber.not.equal(0);
            supporter2Amount.should.be.bignumber.not.equal(0);
            supporter3Amount.should.be.bignumber.not.equal(0);
            (depositAmount - initialDeposit).should.be.bignumber.equal(episodePrice * depositRate / decimals);


            //구매 정보 확인
            const buyerDetail = await content.getEpisodeDetail.call(0, {from: user});
            buyerDetail[0].should.be.equal(episodeRecord);
            buyerDetail[1].should.be.bignumber.equal(episodePrice);
            buyerDetail[2].should.be.bignumber.equal(1);
        });

        it("change marketer rate", async () => {
            const marketerRate = 0;
            const compareAmount = new BigNumber(1.5 * decimals);

            await content.updateContent(
                contentRecord,
                marketerRate,
                {from: writer}
            ).should.be.fulfilled;

            const rate = await content.getMarketerRate.call({from: writer});
            rate.should.be.bignumber.equal(0);

            const marketerKey = await marketers.generateMarketerKey.call({from:marketer2});
            await marketers.setMarketerKey(String(marketerKey), {from: marketer2});
            const marketerAddress = await marketers.getMarketerAddress(marketerKey, {from: marketer2});

            const tempJson = {
                "cdAddress": String(cd),
                "contentAddress": String(content.address),
                "episodeIndex": 0,
                "marketer": String(marketerAddress)
            };

            const purchaseJson = JSON.stringify(tempJson);
            const userAmount = await token.balanceOf.call(user2, {from: owner});

            await token.approveAndCall(
                distributor.address,
                episodePrice,
                purchaseJson,
                {from: user2}
            );

            const marketerAmount = await token.balanceOf.call(marketer2, {from: owner});
            marketerAmount.should.be.bignumber.equal(compareAmount);
        });

        it("repurchase user", async() => {
            const tempJson = {
                "cdAddress": String(cd),
                "contentAddress": String(content.address),
                "episodeIndex": 0,
                "marketer": String(0)
            };

            const purchaseJson = JSON.stringify(tempJson);
            const userAmount = await token.balanceOf.call(user2, {from: owner});

            //이미 구매한 유저가 재 구매를 할 경우 revert 시킴
            await token.approveAndCall(
                distributor.address,
                episodePrice,
                purchaseJson,
                {from: user2}
            ).should.be.rejected;
        });

        it("free content", async() => {
            const tempJson = {
                "cdAddress": String(cd),
                "contentAddress": String(content.address),
                "episodeIndex": 1,
                "marketer": String(0)
            };

            const purchaseJson = JSON.stringify(tempJson);

            //무료 컨텐츠의 경우 에피소드 구매 목록만 업데이트
            await token.approveAndCall(
                distributor.address,
                0,
                purchaseJson,
                {from: freeUser}
            ).should.be.fulfilled;

            const purchaseInfo = await content.getEpisodeDetail.call(1, {from: freeUser}).should.be.fulfilled;

            purchaseInfo[1].should.be.bignumber.equal(0);
            purchaseInfo[2].should.be.bignumber.equal(1);
        });
    });
});
