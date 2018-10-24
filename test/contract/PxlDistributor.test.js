var PXL = artifacts.require("PXL");
var Council = artifacts.require("Council");
var UserPaybackPool = artifacts.require("UserPaybackPool");
var DepositPool = artifacts.require("DepositPool");
var ContentsManager = artifacts.require("ContentsManager");
var Content = artifacts.require("Content");
var FundManager = artifacts.require("FundManager");
var Fund = artifacts.require("Fund");
var PxlDistributor = artifacts.require("PxlDistributor");
var Marketer = artifacts.require("Marketer");
var Report = artifacts.require("Report");
var AccountManager = artifacts.require("AccountManager");
var ApiContents = artifacts.require("ApiContents");

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

    const record = '{"title": "권짱님의 스트레스!!","genres": "액션, 판타지","synopsis": "요괴가 지니고 있는 능력으로 합법적 무력을 행사하고 사회적 문제를 해결하는 단체, \'연옥학원\'. 빼앗긴 심장과 기억을 되찾기 위해 연옥학원에 들어간 좀비, 블루의 모험이 다시 시작된다! 더욱 파워풀한 액션으로 돌아온 연옥학원, 그 두 번째 이야기!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const updateRecord = '{"title": "권짱님의 업그레이드 스트레스!!","genres": "액션, 판타지","synopsis": "요괴가 지니고 있는 능력으로 합법적 무력을 행사하고 사회적 문제를 해결하는 단체, \'연옥학원\'. 빼앗긴 심장과 기억을 되찾기 위해 연옥학원에 들어간 좀비, 블루의 모험이 다시 시작된다! 더욱 파워풀한 액션으로 돌아온 연옥학원, 그 두 번째 이야기!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const episode = '{"title": "똥쟁이님의 신발 구매???????","genres": "일상","synopsis": "여기 이 남자를 보시라! 뭘 해도 어그로 가 끌리는 미친 존재감! 낙천적이며 교활하기 까지한 티이모 유저 제인유와 그의 친구들의 좌충우돌 스토리!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const updateEpisode = '{"title": "똥쟁이님의 조던 11!!!","genres": "일상","synopsis": "여기 이 남자를 보시라! 뭘 해도 어그로 가 끌리는 미친 존재감! 낙천적이며 교활하기 까지한 티이모 유저 제인유와 그의 친구들의 좌충우돌 스토리!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const imageUrl = '{"cuts": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg,https://www.battlecomics.co.kr/webtoons/467"}';

    const episodePrice = new BigNumber(10 * decimals);

    const airdropAmount = 1000 * decimals;
    const fundAvailable = false;

    let token;
    let council;
    let userPayback;
    let deposit;
    let contentsManager;
    let content;
    let fundManager;
    let fund;
    let distributor;
    let marketers;
    let reporter;
    let accountManager;
    let apiContents;

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
        token = await PXL.new({from: owner, gasPrice: 1000000000});
        council = await Council.new(token.address, {from: owner, gasPrice: 1000000000});
        userPayback = await UserPaybackPool.new(council.address, userPaybackPoolInterval, {from: owner, gasPrice: 1000000000});
        deposit = await DepositPool.new(council.address, {from: owner, gasPrice: 1000000000});
        contentsManager = await ContentsManager.new(council.address, {from: owner, gasPrice: 1000000000});
        fundManager = await FundManager.new(council.address, {from: owner, gasPrice: 1000000000});
        distributor = await PxlDistributor.new(council.address, {from: owner, gasPrice: 1000000000});
        marketers = await Marketer.new({from: owner, gasPrice: 1000000000});
        reporter = await Report.new(council.address, {from: owner, gasPrice: 1000000000});
        accountManager = await AccountManager.new(council.address, airdropAmount, {from: owner, gasPrice: 1000000000});
        apiContents = await ApiContents.new(council.address, contentsManager.address, {from: owner});
        //===========================    컨트랙트 배포 종료   ===========================

        //===========================    PXL 컨트랙트 오너 변경 및 토큰 발행 시작    ===========================
        await token.mint(initialBalance, {from: owner, gasPrice: 1000000000}).should.be.fulfilled;
        await token.unlock({from: owner}).should.be.fulfilled;
        await token.transfer(accountManager.address, 100000 * decimals, {from: owner});
        //===========================    PXL 컨트랙트 오너 변경 및 토큰 발행 종료    ===========================

        //===========================    위원회 초기 값 설정 시작    ===========================
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
            marketerDefaultRate
        ).should.be.fulfilled;

        await council.initialPictionAddress(
            userPayback.address,
            deposit.address,
            distributor.address,
            marketers.address,
            reporter.address,
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
        //===========================    위원회 초기 값 설정 종료    ===========================

    });

    describe("PXL distribution", async() => {
        before("Create new account", async () =>{
            //(writer, marketer1, user, user2, freeUser)
            await accountManager.createNewAccount(
                "writer",
                "writer1234",
                "writer private key",
                writer,
                {from: writer}
            ).should.be.fulfilled;

            await accountManager.createNewAccount(
                "marketer1",
                "marketer11234",
                "marketer1 private key",
                marketer1,
                {from: marketer1}
            ).should.be.fulfilled;

            await accountManager.createNewAccount(
                "user",
                "user1234",
                "user private key",
                user,
                {from: user}
            ).should.be.fulfilled;

            await accountManager.createNewAccount(
                "user2",
                "user21234",
                "user2 private key",
                user2,
                {from: user2}
            ).should.be.fulfilled;

            await accountManager.createNewAccount(
                "freeUser",
                "freeUser1234",
                "freeUser private key",
                freeUser,
                {from: freeUser}
            ).should.be.fulfilled;

            let _isRegisterd = await accountManager.isRegistered.call("writer", {from:writer});
            _isRegisterd.should.be.equal(true);
            _isRegisterd = await accountManager.isRegistered.call("user", {from:user});
            _isRegisterd.should.be.equal(true);
            _isRegisterd = await accountManager.isRegistered.call("user2", {from:user2});
            _isRegisterd.should.be.equal(true);
            _isRegisterd = await accountManager.isRegistered.call("marketer1", {from:marketer1});
            _isRegisterd.should.be.equal(true);
            _isRegisterd = await accountManager.isRegistered.call("freeUser", {from:freeUser});
            _isRegisterd.should.be.equal(true);
        });

        before("Add contents.", async () => {
            const marketerRate = 0.1 * decimals;

            //===========================    Initial Desposit 전송 시작    ===========================

                const _toAddress = await council.getContentsManager.call({from: writer});
                
                await token.approveAndCall(_toAddress, initialDeposit, "", {from: writer});

                const _initialDeposit = await apiContents.getInitialDeposit.call(writer, {from: writer});
                _initialDeposit.should.be.bignumber.equal(initialDeposit);
            //===========================    Initial Desposit 전송 종료    ===========================

            //===========================    콘텐츠 생성 시작    ===========================
            await apiContents.addContents(record, 0.1 * decimals, {from:writer});

            let _contentsAddress = await apiContents.getWriterContentsAddress.call(writer, {from:writer});
            _contentsAddress.length.should.be.equal(1);

            const _contentsRecords = await apiContents.getContentsRecord.call(_contentsAddress, {from: writer});
            const _record = JSON.parse(web3.toUtf8(_contentsRecords[1]));

            _record.length.should.be.equal(1);
            _record[0].title.should.be.equal('권짱님의 스트레스!!');
            _record[0].genres.should.be.equal('액션, 판타지');
            //===========================    콘텐츠 생성 종료    ===========================

            //===========================    펀드 생성 시작    ===========================
            // fund 최신 코드 미 적용으로 테스트 코드는 제거
            
            // const startTime = Date.now() + 3000;    // 현재시간 +3초
            // const endTime = startTime + 5000;      //펀드 종료 시간 = 시작시간 + 5초

            // await fundManager.addFund(
            //     content.address,
            //     writer,
            //     startTime,
            //     endTime,
            //     1,
            //     600,
            //     5 * decimals,
            //     "리오의 스트레스에 투자하라!!!",
            //     {from: writer, gasPrice: 1000000000}
            // );

            // const fundAddress = await fundManager.getFunds.call(content.address, {from: writer});
            // const fundLength = fundAddress.length;

            // fundLength.should.be.equal(1);

            // fund = Fund.at(fundAddress[0]);

            // //펀드 시작시간 +3초 뒤 투자 시작
            // const supportTokenPromise = new Promise( async (resolve, reject) => {
            //     setTimeout( async() => {
            //         await token.approveAndCall(
            //             fund.address,
            //             500 * decimals,
            //             "",
            //             {from: supporter, gasPrice: 1000000000}
            //         );

            //         await token.approveAndCall(
            //             fund.address,
            //             500 * decimals,
            //             "",
            //             {from: supporter2, gasPrice: 1000000000}
            //         );

            //         await token.approveAndCall(
            //             fund.address,
            //             300 * decimals,
            //             "",
            //             {from: supporter3, gasPrice: 1000000000}
            //         );

            //         resolve();
            //     }, 5000);
            // });
            // await supportTokenPromise;

            // //펀드 종료시간 +2초 뒤 서포터 풀 생성
            // const startPromise = new Promise( async (resolve, reject) => {
            //     setTimeout( async() => {
            //         await fund.createSupporterPool({from: writer, gasPrice: 1000000000});

            //         resolve();
            //     }, 10000);
            // });
            // await startPromise;
            //===========================    펀드 생성 종료    ===========================


            //===========================    에피소드 생성 시작    ===========================
            
            const _contentsDetail = await apiContents.getWriterContentsList.call(writer, {from: writer});
            _contentsAddress = _contentsDetail[0][0];

            await apiContents.addEpisode(_contentsAddress, episode, imageUrl, episodePrice, {from: writer}).should.be.fulfilled;

            let _episodeDetail = await apiContents.getEpisodeFullList(_contentsAddress, {from: writer});
            let _episodeRecord = JSON.parse(web3.toUtf8(_episodeDetail[0]));
            let _episodePrice = _episodeDetail[1];
            let _episodeBuyCount = _episodeDetail[2];
            let _episodePurchased = _episodeDetail[3];

            _episodePrice.length.should.be.equal(_episodeBuyCount.length);
            _episodeBuyCount.length.should.be.equal(_episodePurchased.length);

            _episodeRecord[0].title.should.be.equal('똥쟁이님의 신발 구매???????');
            episodePrice.should.be.bignumber.equal(_episodePrice[0]);
            _episodeBuyCount[0].toNumber().should.be.equal(0);
            _episodePurchased[0].should.be.equal(true);

            // 무료 에피소드
            await apiContents.addEpisode(_contentsAddress, episode, imageUrl, 0, {from: writer}).should.be.fulfilled;

            _episodeDetail = await apiContents.getEpisodeFullList(_contentsAddress, {from: writer});
            _episodeRecord = JSON.parse(web3.toUtf8(_episodeDetail[0]));
            _episodePrice = _episodeDetail[1];
            _episodeBuyCount = _episodeDetail[2];
            _episodePurchased = _episodeDetail[3];

            _episodeRecord.length.should.be.equal(2);
            _episodePrice.length.should.be.equal(_episodeBuyCount.length);
            _episodeBuyCount.length.should.be.equal(_episodePurchased.length);

            _episodeRecord[1].title.should.be.equal('똥쟁이님의 신발 구매???????');
            _episodePrice[1].should.be.bignumber.equal(0);
            _episodeBuyCount[1].toNumber().should.be.equal(0);
            _episodePurchased[1].should.be.equal(true);
            //===========================    에피소드 생성 종료    ===========================
        });

        it("purchase episode", async() => {
            const marketerRate = 0.1 * decimals;

            const marketerKey = await marketers.generateMarketerKey.call({from:marketer1});
            await marketers.setMarketerKey(String(marketerKey), {from: marketer1, gasPrice: 1000000000});
            const marketerAddress = await marketers.getMarketerAddress(marketerKey, {from: marketer1});

            const _contentsDetail = await apiContents.getWriterContentsAddress.call(writer, {from: writer});
            _contentsDetail.length.should.be.equal(1);
            const _contentsAddress = _contentsDetail[0];
            const _episodeLength = await apiContents.getEpisodeLength(_contentsAddress, {from: user});
            _episodeLength.should.be.bignumber.equal(2);

            await token.approveAndCall(
                distributor.address, 
                episodePrice,
                _contentsAddress + marketerAddress.substr(2) + toBigNumber(0).substr(2),
                {from: user, gasPrice: 1000000000}
            );

            const cdRate = await council.getCdRate();
            const depositRate = await council.getDepositRate();
            const userPaybackRate = await council.getUserPaybackRate();

            const cdAmount = await token.balanceOf.call(cd, {from: cd});
            const marketerAmount = await token.balanceOf.call(marketer1, {from: owner});
            const depositAmount = await token.balanceOf.call(deposit.address, {from: owner});
            const writerAmount = await token.balanceOf.call(writer, {from: owner});
            const distributorAmount = await token.balanceOf.call(distributor.address, {from: owner});
            const userpaybackAmount = await token.balanceOf.call(userPayback.address, {from: owner});

            const buyerDetail = await apiContents.getEpisodeDetail.call(_contentsAddress, 0, user, {from: user});

            console.log();
            console.log(colors.yellow.bold("\t========== Pxl distribution amount =========="));
            console.log(colors.yellow("\tepisode price : " + buyerDetail[1].toNumber() / decimals));
            console.log(colors.yellow("\tcdAmount(15%) : " + cdAmount.toNumber() / decimals));
            console.log(colors.yellow("\tuserpaybackAmount(2%) : " + userpaybackAmount.toNumber() / decimals));
            console.log(colors.yellow("\tdepositAmount(3%) : " + (depositAmount - initialDeposit) / decimals));
            console.log(colors.yellow("\tmarketerAmount(10%) : " + (marketerAmount - airdropAmount) / decimals));
            console.log(colors.yellow("\twriter Amount : " + writerAmount.toNumber() / decimals));
            console.log(colors.yellow("\tPXL Distributor Amount : " + distributorAmount.toNumber() / decimals));
            console.log();
            console.log();

            //마케터 주소 확인
            marketerAddress.should.be.equal(marketer1);

            // 분배 된 pixel 양 확인
            distributorAmount.should.be.bignumber.equal(0);
            cdAmount.should.be.bignumber.equal(episodePrice * cdRate / decimals);
            (marketerAmount - airdropAmount).should.be.bignumber.equal(episodePrice * marketerRate / decimals);
            userpaybackAmount.should.be.bignumber.equal(episodePrice * userPaybackRate / decimals);
            (depositAmount - initialDeposit).should.be.bignumber.equal(episodePrice * depositRate / decimals);

            //구매 정보 확인
            buyerDetail[0].should.be.equal(episode);
            buyerDetail[1].should.be.bignumber.equal(episodePrice);
            buyerDetail[2].should.be.bignumber.equal(1);
            buyerDetail[3].should.be.equal(true);
        });

        it("repurchase user", async() => {
            const userAmount = await token.balanceOf.call(user2, {from: owner});

            const _contentsDetail = await apiContents.getWriterContentsAddress.call(writer, {from: writer});
            _contentsDetail.length.should.be.equal(1);
            const _contentsAddress = _contentsDetail[0];

            //이미 구매한 유저가 재 구매를 할 경우 revert 시킴
            await token.approveAndCall(
                distributor.address,
                episodePrice,
                _contentsAddress + toAddress(0).substr(2) + toBigNumber(0).substr(2),
                {from: user, gasPrice: 1000000000}
            ).should.be.rejected;
        });

        it("free content", async() => {
            const _contentsDetail = await apiContents.getWriterContentsAddress.call(writer, {from: writer});
            _contentsDetail.length.should.be.equal(1);
            const _contentsAddress = _contentsDetail[0];

            //무료 컨텐츠의 경우 에피소드 구매 목록만 업데이트
            await token.approveAndCall(
                distributor.address,
                0,
                _contentsAddress + toAddress(0).substr(2) + toBigNumber(1).substr(2),
                {from: freeUser, gasPrice: 1000000000}
            ).should.be.fulfilled;

            const buyerDetail = await apiContents.getEpisodeDetail.call(_contentsAddress, 1, freeUser, {from: freeUser});
            
            console.log();
            console.log(colors.yellow("\tfree episode purchase"));
            console.log(colors.yellow("\tepisode price : " + buyerDetail[1]));
            console.log(colors.yellow("\tepisode purchase count : " + buyerDetail[2]));
            console.log();
            console.log();

            buyerDetail[1].should.be.bignumber.equal(0);
            buyerDetail[2].should.be.bignumber.equal(1);
        });
    });
});
