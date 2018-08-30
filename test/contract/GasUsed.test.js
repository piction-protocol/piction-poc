const { timer } = require("../helpers/timer");

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
var AccountManager = artifacts.require("AccountManager");

const colors = require('colors/safe');

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
    const reporter = accounts[11];
    const deploy = accounts[12];

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

    const contentRecord = '{"title": "리오의 스트레스!!","genres": "액션, 판타지","synopsis": "요괴가 지니고 있는 능력으로 합법적 무력을 행사하고 사회적 문제를 해결하는 단체, \'연옥학원\'. 빼앗긴 심장과 기억을 되찾기 위해 연옥학원에 들어간 좀비, 블루의 모험이 다시 시작된다! 더욱 파워풀한 액션으로 돌아온 연옥학원, 그 두 번째 이야기!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const episodeRecord = '{"title": "하랑이의 신발 구매???????","genres": "일상","synopsis": "여기 이 남자를 보시라! 뭘 해도 어그로 가 끌리는 미친 존재감! 낙천적이며 교활하기 까지한 티이모 유저 제인유와 그의 친구들의 좌충우돌 스토리!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';

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
    let report;

    let beforeBalance;
    let afterBalance;
    let txFee;
    let accumulate = 0;
    let won = 450000;

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

    before("Initial setup", async() => {
        //===========================    컨트랙트 배포 시작    ===========================
        console.log();
        console.log(colors.magenta.bold("\t========== Deploy contract gas usage(1 Gwei) =========="));

        beforeBalance = await web3.eth.getBalance(deploy);

        token = await PXL.new({from: deploy, gasPrice: 1000000000});

        await token.transferOwnership(owner, {from: deploy, gasPrice: 1000000000}).should.be.fulfilled;

        afterBalance = await web3.eth.getBalance(deploy);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\ttoken contract"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        council = await Council.new(token.address, {from: owner, gasPrice: 1000000000});

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\tcouncil contract"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        userPayback = await UserPaybackPool.new(council.address, userPaybackPoolInterval, {from: owner, gasPrice: 1000000000});

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\tuserPaybackPool contract"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        deposit = await DepositPool.new(council.address, {from: owner, gasPrice: 1000000000});

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\tdepositPool contract"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        roleManager = await RoleManager.new({from: owner, gasPrice: 1000000000});

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\troleManager contract"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        contentsManager = await ContentsManager.new(council.address, {from: owner, gasPrice: 1000000000});

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\tcontentsManager contract"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        fundManager = await FundManager.new(council.address, {from: owner, gasPrice: 1000000000});

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\tfundManager contract"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        distributor = await PxlDistributor.new(council.address, {from: owner, gasPrice: 1000000000});

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\tpxlDistributor contract"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        marketers = await Marketer.new({from: owner, gasPrice: 1000000000});

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\tmarketers contract"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        accountManager = await AccountManager.new(council.address, 0, {from: owner, gasPrice: 1000000000});

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\tAccountManager contract"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        report = await Report.new(council.address, {from: owner, gasPrice: 1000000000});

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\treport contract"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();
        console.log(colors.blue.bgWhite.bold("\tDeploy contract total Amount : " + accumulate / decimals + " Ether (￦ " + Math.round((accumulate / decimals) * won) + ")"));
        console.log();
        console.log();
        //===========================    컨트랙트 배포 종료   ===========================


        //===========================    위원회 초기 값 설정 시작    ===========================
        console.log();
        console.log(colors.magenta.bold("\t========== Council initial setting gas usage(1 Gwei) =========="));

        beforeBalance = await web3.eth.getBalance(owner);

        await council.initialValue(
            initialDeposit,
            reportRegistrationFee,
            {from: owner, gasPrice: 1000000000}
        );

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = txFee;
        console.log(colors.magenta("\tinitialValue"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        await council.initialRate(
            cdRate,
            depositRate,
            userPaybackRate,
            reportRewardRate,
            marketerDefaultRate,
            {from: owner, gasPrice: 1000000000}
        );

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\tinitialRate"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        await council.initialPictionAddress(
            userPayback.address,
            deposit.address,
            distributor.address,
            marketers.address,
            report.address,
            {from: owner, gasPrice: 1000000000}
        );

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\tinitialPictionAddress"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        await council.initialManagerAddress(
            roleManager.address,
            contentsManager.address,
            fundManager.address,
            accountManager.address,
            {from: owner, gasPrice: 1000000000}
        );

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = accumulate + txFee;
        console.log(colors.magenta("\tinitialManagerAddress"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();
        console.log(colors.blue.bgWhite.bold("\tCouncil initial setting total Amount : " + accumulate / decimals + " Ether (￦ " + Math.round((accumulate / decimals) * won) + ")"));
        console.log();
        console.log();
        //===========================    위원회 초기 값 설정 종료    ===========================


        //===========================    PxlDistributor 권한 등록 시작    ===========================
        console.log();
        console.log(colors.magenta.bold("\t========== Add role gas usage(1 Gwei) =========="));

        beforeBalance = await web3.eth.getBalance(owner);

        await roleManager.addAddressToRole(distributor.address, "PXL_DISTRIBUTOR", {from: owner, gasPrice: 1000000000});

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = txFee;
        console.log(colors.magenta("\tpxlDistributor add role"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();
        console.log(colors.blue.bgWhite.bold("\tAdd role total Amount : " + accumulate / decimals + " Ether (￦ " + Math.round((accumulate / decimals) * won) + ")"));
        console.log();
        console.log();
        //===========================    PxlDistributor 권한 등록 종료    ===========================


        //===========================    토큰 전송 시작    ===========================
        console.log();
        console.log(colors.magenta.bold("\t========== Token transfer gas usage(1 Gwei) =========="));

        beforeBalance = await web3.eth.getBalance(owner);

        await token.mint(initialBalance, {from: owner, gasPrice: 1000000000}).should.be.fulfilled;

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = txFee;
        console.log(colors.magenta("\tmint token"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();


        beforeBalance = await web3.eth.getBalance(owner);

        await token.unlock({from: owner, gasPrice: 1000000000}).should.be.fulfilled;

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate = txFee;
        console.log(colors.magenta("\ttoken unlock"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        await token.transfer(writer, 100 * decimals, {from: owner, gasPrice: 1000000000}).should.be.fulfilled;

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate =  accumulate + txFee;
        console.log(colors.magenta("\ttoken transfer(100pxl)"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        await token.transfer(supporter, 500 * decimals, {from: owner, gasPrice: 1000000000}).should.be.fulfilled;

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate =  accumulate + txFee;
        console.log(colors.magenta("\ttoken transfer(500pxl)"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        await token.transfer(user, 1000 * decimals, {from: owner, gasPrice: 1000000000}).should.be.fulfilled;

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate =  accumulate + txFee;
        console.log(colors.magenta("\ttoken transfer(1,000pxl)"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        await token.transfer(user2, 1000 * decimals, {from: owner, gasPrice: 1000000000}).should.be.fulfilled;

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate =  accumulate + txFee;
        console.log(colors.magenta("\ttoken transfer(1,000pxl)"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        await token.transfer(supporter2, 500 * decimals, {from: owner, gasPrice: 1000000000}).should.be.fulfilled;

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate =  accumulate + txFee;
        console.log(colors.magenta("\ttoken transfer(500pxl)"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        await token.transfer(supporter3, 300 * decimals, {from: owner, gasPrice: 1000000000}).should.be.fulfilled;

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate =  accumulate + txFee;
        console.log(colors.magenta("\ttoken transfer(300pxl)"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        beforeBalance = await web3.eth.getBalance(owner);

        await token.transfer(reporter, 100 * decimals, {from: owner, gasPrice: 1000000000}).should.be.fulfilled;

        afterBalance = await web3.eth.getBalance(owner);
        txFee = beforeBalance - afterBalance;
        accumulate =  accumulate + txFee;
        console.log(colors.magenta("\ttoken transfer(100pxl)"));
        console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
        console.log();

        console.log(colors.blue.bgWhite.bold("\tToken transfer total Amount : " + accumulate / decimals + " Ether (￦ " + Math.round((accumulate / decimals) * won) + ")"));
        console.log();
        console.log();
        //===========================    토큰 전송 종료    ===========================
    });

    describe("PXL distribution", async() => {
        before("contents & fund", async () => {
            const marketerRate = 0.1 * decimals;

            //===========================    콘텐츠 생성 시작    ===========================
            console.log();
            console.log(colors.magenta.bold("\t========== Add content gas usage(1 Gwei) =========="));

            beforeBalance = await web3.eth.getBalance(writer);

            await token.approveAndCall(
                contentsManager.address,
                initialDeposit,
                "",
                {from: writer, gasPrice: 1000000000}
            ).should.be.fulfilled;

            afterBalance = await web3.eth.getBalance(writer);
            txFee = beforeBalance - afterBalance;
            accumulate =  txFee;
            console.log(colors.magenta("\ttransfer CP initial deposit"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();

            beforeBalance = await web3.eth.getBalance(writer);

            await contentsManager.addContents(
                contentRecord,
                marketerRate,
                {from: writer, gasPrice: 1000000000}
            ).should.be.fulfilled;

            afterBalance = await web3.eth.getBalance(writer);
            txFee = beforeBalance - afterBalance;
            accumulate = accumulate + txFee;
            console.log(colors.magenta("\tadd contents"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();
            console.log(colors.blue.bgWhite.bold("\tAdd content total Amount : " + accumulate / decimals + " Ether (￦ " + Math.round((accumulate / decimals) * won) + ")"));
            console.log();
            console.log();

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
            const startTime = Date.now() + 3000;    // 현재시간 +3초
            const endTime = startTime + 5000;      //펀드 종료 시간 = 시작시간 + 5초

            console.log();
            console.log(colors.magenta.bold("\t========== Add fund gas usage(1 Gwei) =========="));

            beforeBalance = await web3.eth.getBalance(writer);

            await fundManager.addFund(
                content.address,
                writer,
                startTime,
                endTime,
                1,
                600,
                5 * decimals,
                "리오의 스트레스에 투자하라!!!",
                {from: writer, gasPrice: 1000000000}
            );

            afterBalance = await web3.eth.getBalance(writer);
            txFee = beforeBalance - afterBalance;
            accumulate =  txFee;
            console.log(colors.magenta("\tadd fund"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();

            const fundAddress = await fundManager.getFunds.call(content.address, {from: writer});
            const fundLength = fundAddress.length;

            fundLength.should.be.equal(1);

            fund = Fund.at(fundAddress[0]);

            //펀드 시작시간 +3초 뒤 투자 시작
            const supportTokenPromise = new Promise( async (resolve, reject) => {
                setTimeout( async() => {
                    beforeBalance = await web3.eth.getBalance(supporter);

                    await token.approveAndCall(
                        fund.address,
                        500 * decimals,
                        "",
                        {from: supporter, gasPrice: 1000000000}
                    );

                    afterBalance = await web3.eth.getBalance(supporter);
                    txFee = beforeBalance - afterBalance;
                    accumulate = accumulate + txFee;
                    console.log(colors.magenta("\tsupporter1 (500pxl)"));
                    console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
                    console.log();

                    beforeBalance = await web3.eth.getBalance(supporter2);

                    await token.approveAndCall(
                        fund.address,
                        500 * decimals,
                        "",
                        {from: supporter2, gasPrice: 1000000000}
                    );

                    afterBalance = await web3.eth.getBalance(supporter2);
                    txFee = beforeBalance - afterBalance;
                    accumulate = accumulate + txFee;
                    console.log(colors.magenta("\tsupporter2 (500pxl)"));
                    console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
                    console.log();

                    beforeBalance = await web3.eth.getBalance(supporter3);

                    await token.approveAndCall(
                        fund.address,
                        300 * decimals,
                        "",
                        {from: supporter3, gasPrice: 1000000000}
                    );

                    afterBalance = await web3.eth.getBalance(supporter3);
                    txFee = beforeBalance - afterBalance;
                    accumulate = accumulate + txFee;
                    console.log(colors.magenta("\tsupporter3 (300pxl)"));
                    console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
                    console.log();

                    resolve();
                }, 5000);
            });
            await supportTokenPromise;

            //펀드 종료시간 +2초 뒤 서포터 풀 생성
            const startPromise = new Promise( async (resolve, reject) => {
                setTimeout( async() => {
                    beforeBalance = await web3.eth.getBalance(writer);

                    await fund.createSupporterPool({from: writer, gasPrice: 1000000000});

                    afterBalance = await web3.eth.getBalance(writer);
                    txFee = beforeBalance - afterBalance;
                    accumulate = accumulate + txFee;
                    console.log(colors.magenta("\tcreate supporter pool"));
                    console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
                    console.log();

                    resolve();
                }, 10000);
            });
            await startPromise;

            console.log(colors.blue.bgWhite.bold("\tAdd fund total Amount : " + accumulate / decimals + " Ether (￦ " + Math.round((accumulate / decimals) * won) + ")"));
            console.log();
            console.log();
            //===========================    펀드 생성 종료    ===========================


            //===========================    에피소드 생성 시작    ===========================
            console.log();
            console.log(colors.magenta.bold("\t========== Add episode gas usage(1 Gwei) =========="));

            const imageUrl = '{"cuts": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg,https://www.battlecomics.co.kr/webtoons/467"}';
            beforeBalance = await web3.eth.getBalance(writer);

            await content.addEpisode(
                episodeRecord,
                imageUrl,
                episodePrice,
                {from: writer, gasPrice: 1000000000}
            );

            afterBalance = await web3.eth.getBalance(writer);
            txFee = beforeBalance - afterBalance;
            accumulate = txFee;
            console.log(colors.magenta("\tadd episode"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();

            const episodeLength = await content.getEpisodeLength.call({from: writer});
            const episodeDetail = await content.getEpisodeDetail.call(0, {from: writer});

            episodeLength.should.be.bignumber.equal(1);
            episodeDetail[0].should.be.equal(episodeRecord);
            episodeDetail[1].should.be.bignumber.equal(episodePrice);
            episodeDetail[2].should.be.bignumber.equal(0);

            // 무료 에피소드

            beforeBalance = await web3.eth.getBalance(writer);

            await content.addEpisode(
                episodeRecord,
                imageUrl,
                0,
                {from: writer, gasPrice: 1000000000}
            );

            afterBalance = await web3.eth.getBalance(writer);
            txFee = beforeBalance - afterBalance;
            accumulate = accumulate + txFee;
            console.log(colors.magenta("\tadd episode(free episode)"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();
            console.log(colors.blue.bgWhite.bold("\tAdd episode total Amount : " + accumulate / decimals + " Ether (￦ " + Math.round((accumulate / decimals) * won) + ")"));
            console.log();
            console.log();

            const episodeLength1 = await content.getEpisodeLength.call({from: writer});
            const episodeDetail1 = await content.getEpisodeDetail.call(1, {from: writer});

            episodeLength1.should.be.bignumber.equal(2);
            episodeDetail1[0].should.be.equal(episodeRecord);
            episodeDetail1[1].should.be.bignumber.equal(0);
            episodeDetail1[2].should.be.bignumber.equal(0);
            //===========================    에피소드 생성 종료    ===========================
        });

        it("purchase episode", async() => {
            const marketerRate = 0.1 * decimals;

            console.log();
            console.log(colors.magenta.bold("\t========== Marketer key generation gas usage(1 Gwei) =========="));

            beforeBalance = await web3.eth.getBalance(marketer1);

            const marketerKey = await marketers.generateMarketerKey.call({from:marketer1});
            await marketers.setMarketerKey(String(marketerKey), {from: marketer1, gasPrice: 1000000000});
            const marketerAddress = await marketers.getMarketerAddress(marketerKey, {from: marketer1});

            afterBalance = await web3.eth.getBalance(marketer1);
            txFee = beforeBalance - afterBalance;
            accumulate = txFee;
            console.log(colors.magenta("\tset marketer key"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();

            const userAmount = await token.balanceOf.call(user, {from: owner});

            console.log();
            console.log(colors.magenta.bold("\t========== Purchase episode gas usage(1 Gwei) =========="));

            beforeBalance = await web3.eth.getBalance(user);

            await token.approveAndCall(
                distributor.address,
                episodePrice,
                cd + content.address.substr(2) + marketerAddress.substr(2) + toBigNumber(0).substr(2),
                {from: user, gasPrice: 1000000000}
            );

            afterBalance = await web3.eth.getBalance(user);
            txFee = beforeBalance - afterBalance;
            accumulate = txFee;
            console.log(colors.magenta("\tpurchase episode"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();
            console.log(colors.blue.bgWhite.bold("\tPurchase episode total Amount : " + accumulate / decimals + " Ether (￦ " + Math.round((accumulate / decimals) * won) + ")"));
            console.log();
            console.log();

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

            const buyerDetail = await content.getEpisodeDetail.call(0, {from: user});

            console.log();
            console.log(colors.yellow.bold("\t========== Pxl distribution amount =========="));
            console.log(colors.yellow("\tepisode price : " + buyerDetail[1].toNumber() / decimals));
            console.log(colors.yellow("\tcdAmount(15%) : " + cdAmount.toNumber() / decimals));
            console.log(colors.yellow("\tuserpaybackAmount(2%) : " + userpaybackAmount.toNumber() / decimals));
            console.log(colors.yellow("\tdepositAmount(3% + with initial deposit) : " + depositAmount.toNumber() / decimals));
            console.log(colors.yellow("\tmarketerAmount(10%) : " + marketerAmount.toNumber() / decimals));
            console.log(colors.yellow("\tsupporter1 Amount : " + supporterAmount.toNumber() / decimals));
            console.log(colors.yellow("\tsupporter2 Amount : " + supporter2Amount.toNumber() / decimals));
            console.log(colors.yellow("\tsupporter3 Amount : " + supporter3Amount.toNumber() / decimals));
            console.log(colors.yellow("\twriter Amount : " + writerAmount.toNumber() / decimals));
            console.log(colors.yellow("\tPXL Distributor Amount : " + distributorAmount.toNumber() / decimals));
            console.log();
            console.log();

            //마케터 주소 확인
            marketerAddress.should.be.equal(marketer1);

            // 분배 된 pixel 양 확인
            distributorAmount.should.be.bignumber.equal(0);
            cdAmount.should.be.bignumber.equal(episodePrice * cdRate / decimals);
            marketerAmount.should.be.bignumber.equal(episodePrice * marketerRate / decimals);
            userpaybackAmount.should.be.bignumber.equal(episodePrice * userPaybackRate / decimals);
            supporterAmount.should.be.bignumber.not.equal(0);
            supporter2Amount.should.be.bignumber.not.equal(0);
            supporter3Amount.should.be.bignumber.not.equal(0);
            (depositAmount - initialDeposit).should.be.bignumber.equal(episodePrice * depositRate / decimals);

            //구매 정보 확인
            buyerDetail[0].should.be.equal(episodeRecord);
            buyerDetail[1].should.be.bignumber.equal(episodePrice);
            buyerDetail[2].should.be.bignumber.equal(1);
        });

        it("change marketer rate", async () => {
            const marketerRate = 0;
            const compareAmount = new BigNumber(1.5 * decimals);    //위원회 기본 비율

            await content.updateContent(
                contentRecord,
                marketerRate,
                {from: writer, gasPrice: 1000000000}
            ).should.be.fulfilled;

            const rate = await content.getMarketerRate.call({from: writer});
            rate.should.be.bignumber.equal(0);

            const marketerKey = await marketers.generateMarketerKey.call({from:marketer2});
            await marketers.setMarketerKey(String(marketerKey), {from: marketer2});
            const marketerAddress = await marketers.getMarketerAddress(marketerKey, {from: marketer2});

            const userAmount = await token.balanceOf.call(user2, {from: owner});

            await token.approveAndCall(
                distributor.address,
                episodePrice,
                cd + content.address.substr(2) + marketerAddress.substr(2) + toBigNumber(0).substr(2),
                {from: user2, gasPrice: 1000000000}
            );

            const marketerAmount = await token.balanceOf.call(marketer2, {from: owner});
            console.log();
            console.log(colors.yellow("\tmarketer amount(default rate) : " + marketerAmount.toNumber() / decimals));
            console.log();
            console.log();

            marketerAmount.should.be.bignumber.equal(compareAmount);
        });

        it("repurchase user", async() => {
            const userAmount = await token.balanceOf.call(user2, {from: owner});

            //이미 구매한 유저가 재 구매를 할 경우 revert 시킴
            await token.approveAndCall(
                distributor.address,
                episodePrice,
                cd + content.address.substr(2) + toAddress(0).substr(2) + toBigNumber(0).substr(2),
                {from: user2, gasPrice: 1000000000}
            ).should.be.rejected;
        });

        it("free content", async() => {
            console.log();
            console.log(colors.magenta.bold("\t========== Purchase free episode gas usage(1 Gwei) =========="));

            beforeBalance = await web3.eth.getBalance(freeUser);

            //무료 컨텐츠의 경우 에피소드 구매 목록만 업데이트
            await token.approveAndCall(
                distributor.address,
                0,
                cd + content.address.substr(2) + toAddress(0).substr(2) + toBigNumber(1).substr(2),
                {from: freeUser, gasPrice: 1000000000}
            ).should.be.fulfilled;

            afterBalance = await web3.eth.getBalance(freeUser);
            txFee = beforeBalance - afterBalance;
            accumulate = txFee;
            console.log(colors.magenta("\tpurchase episode"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();
            console.log(colors.blue.bgWhite.bold("\tPurchase free episode total Amount : " + accumulate / decimals + " Ether (￦ " + Math.round((accumulate / decimals) * won) + ")"));
            console.log();
            console.log();

            const purchaseInfo = await content.getEpisodeDetail.call(1, {from: freeUser}).should.be.fulfilled;

            console.log();
            console.log(colors.yellow("\tfree episode purchase info.."));
            console.log(colors.yellow("\tepisode price : " + purchaseInfo[1]));
            console.log(colors.yellow("\tepisode purchase count : " + purchaseInfo[2]));
            console.log();
            console.log();

            purchaseInfo[1].should.be.bignumber.equal(0);
            purchaseInfo[2].should.be.bignumber.equal(1);
        });
    });
    describe("Report", async() => {
        it("reg fee", async() => {
            console.log();
            console.log(colors.magenta.bold("\t========== Report send regFee gas usage(1 Gwei) =========="));

            beforeBalance = await web3.eth.getBalance(reporter);

            await token.approveAndCall(
                report.address,
                reportRegistrationFee,
                "",
                {from: reporter, gasPrice: 1000000000}
            ).should.be.fulfilled;

            afterBalance = await web3.eth.getBalance(reporter);
            txFee = beforeBalance - afterBalance;
            accumulate = txFee;

            console.log(colors.magenta("\tReport send regFee"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();
        });

        it("send report", async() => {
            console.log();
            console.log(colors.magenta.bold("\t========== Send report gas usage(1 Gwei) =========="));

            beforeBalance = await web3.eth.getBalance(reporter);

            await report.sendReport(content.address, "1234567890", {from: reporter, gasPrice: 1000000000}).should.be.fulfilled;

            afterBalance = await web3.eth.getBalance(reporter);
            txFee = beforeBalance - afterBalance;
            accumulate = txFee + accumulate;

            console.log(colors.magenta("\tReport send string 10"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();

            beforeBalance = await web3.eth.getBalance(reporter);

            await report.sendReport(content.address, "1234567890", {from: reporter, gasPrice: 1000000000}).should.be.fulfilled;

            afterBalance = await web3.eth.getBalance(reporter);
            txFee = beforeBalance - afterBalance;
            //accumulate = txFee + accumulate;

            console.log(colors.magenta("\tReport send string 10"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();

            beforeBalance = await web3.eth.getBalance(reporter);

            await report.sendReport(content.address, "12345678901234567890", {from: reporter, gasPrice: 1000000000}).should.be.fulfilled;

            afterBalance = await web3.eth.getBalance(reporter);
            txFee = beforeBalance - afterBalance;
            //accumulate = txFee + accumulate;

            console.log(colors.magenta("\tReport send string 20"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();

            console.log(colors.blue.bgWhite.bold("\tReport send total Amount : " + accumulate / decimals + " Ether (￦ " + Math.round((accumulate / decimals) * won) + ")"));
            console.log();
            console.log();
        });

        it("judge", async() => {
            console.log();
            console.log(colors.magenta.bold("\t========== Judge RegFee Deduction gas usage(1 Gwei) =========="));

            beforeBalance = await web3.eth.getBalance(owner);

            await council.judge(0, content.address, reporter, 0.1 * decimals, {from: owner, gasPrice: 1000000000}).should.be.fulfilled;

            afterBalance = await web3.eth.getBalance(owner);
            txFee = beforeBalance - afterBalance;
            accumulate = txFee;

            console.log(colors.magenta("\tJudge"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();

            console.log();
            console.log(colors.magenta.bold("\t========== Judge RegFee Deduction And Block gas usage(1 Gwei) =========="));

            beforeBalance = await web3.eth.getBalance(owner);

            await council.judge(1, content.address, reporter, 0.5 * decimals, {from: owner, gasPrice: 1000000000}).should.be.fulfilled;

            afterBalance = await web3.eth.getBalance(owner);
            txFee = beforeBalance - afterBalance;
            accumulate = txFee + accumulate;

            console.log(colors.magenta("\tJudge"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();

            console.log();
            console.log(colors.magenta.bold("\t========== Judge Rewerd gas usage(1 Gwei) =========="));

            beforeBalance = await web3.eth.getBalance(owner);

            await council.judge(2, content.address, reporter, 0, {from: owner, gasPrice: 1000000000}).should.be.fulfilled;

            afterBalance = await web3.eth.getBalance(owner);
            txFee = beforeBalance - afterBalance;
            accumulate = txFee + accumulate;

            console.log(colors.magenta("\tJudge"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();

            console.log(colors.blue.bgWhite.bold("\tJudge total Amount : " + accumulate / decimals + " Ether (￦ " + Math.round((accumulate / decimals) * won) + ")"));
            console.log();
            console.log();
        });

        it("return", async() => {
            await timer(12000);

            console.log();
            console.log(colors.magenta.bold("\t========== RegFee Return gas usage(1 Gwei) =========="));

            beforeBalance = await web3.eth.getBalance(reporter);

            await report.returnRegFee({from: reporter, gasPrice: 1000000000}).should.be.fulfilled;

            afterBalance = await web3.eth.getBalance(reporter);
            txFee = beforeBalance - afterBalance;
            accumulate = txFee

            console.log(colors.magenta("\tRegFee Return"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();

            console.log();
            console.log(colors.magenta.bold("\t========== Diposit Release gas usage(1 Gwei) =========="));

            beforeBalance = await web3.eth.getBalance(writer);

            await deposit.release(content.address, {from: writer, gasPrice: 1000000000})

            afterBalance = await web3.eth.getBalance(writer);
            txFee = beforeBalance - afterBalance;
            accumulate = txFee

            console.log(colors.magenta("\tRegFee Return"));
            console.log(colors.magenta("\tActual Tx Cost/Fee : " + txFee / decimals + " Ether (￦ " + Math.round((txFee / decimals) * won) + ")"));
            console.log();
        });

    });
});
