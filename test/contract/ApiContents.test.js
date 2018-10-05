var PXL = artifacts.require("PXL");
var Council = artifacts.require("Council");
var ApiContents = artifacts.require("ApiContents");
var Content = artifacts.require("Content");
var ContentsManager = artifacts.require("ContentsManager");
var AccountManager = artifacts.require("AccountManager");
var DepositPool = artifacts.require("DepositPool");

const BigNumber = web3.BigNumber;

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("ApiContents", function (accounts) {
    const owner = accounts[0];
    const writer = accounts[1];
    const user1 = accounts[2];
    const user2 = accounts[3];

    const decimals = Math.pow(10, 18);
    const initialBalance = new BigNumber(1000000000 * decimals);

    const initialDeposit = new BigNumber(100 * decimals);
    const reportRegistrationFee = new BigNumber(50 * decimals);
    const fundAvailable = true;

    const cdRate = 15 * decimals;
    const depositRate = 3 * decimals;
    const userPaybackRate = 2 * decimals;
    const reportRewardRate = 10 * decimals;
    const marketerRate = 10 * decimals;

    const createPoolInterval = 86400;
    const airdropAmount = 1000 * decimals;

    const addressZero = "0x0000000000000000000000000000000000000000";

    const record = '{"title": "권짱님의 스트레스!!","genres": "액션, 판타지","synopsis": "요괴가 지니고 있는 능력으로 합법적 무력을 행사하고 사회적 문제를 해결하는 단체, \'연옥학원\'. 빼앗긴 심장과 기억을 되찾기 위해 연옥학원에 들어간 좀비, 블루의 모험이 다시 시작된다! 더욱 파워풀한 액션으로 돌아온 연옥학원, 그 두 번째 이야기!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const updateRecord = '{"title": "권짱님의 업그레이드 스트레스!!","genres": "액션, 판타지","synopsis": "요괴가 지니고 있는 능력으로 합법적 무력을 행사하고 사회적 문제를 해결하는 단체, \'연옥학원\'. 빼앗긴 심장과 기억을 되찾기 위해 연옥학원에 들어간 좀비, 블루의 모험이 다시 시작된다! 더욱 파워풀한 액션으로 돌아온 연옥학원, 그 두 번째 이야기!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const episode = '{"title": "똥쟁이님의 신발 구매???????","genres": "일상","synopsis": "여기 이 남자를 보시라! 뭘 해도 어그로 가 끌리는 미친 존재감! 낙천적이며 교활하기 까지한 티이모 유저 제인유와 그의 친구들의 좌충우돌 스토리!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const imageUrl = '{"cuts": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg,https://www.battlecomics.co.kr/webtoons/467"}';

    let token;
    let council;
    let apiContents;
    let content;
    let contentsManager;
    let accountManager;
    let depositPool;

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
        contentsManager = await ContentsManager.new(council.address, {from: owner});
        accountManager = await AccountManager.new(council.address, airdropAmount, {from: owner});
        depositPool = await DepositPool.new(council.address, {from:owner});

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
            depositPool.address,
            depositPool.address,
            depositPool.address,
            depositPool.address,
            depositPool.address
        ).should.be.fulfilled;

        await council.initialManagerAddress(
            contentsManager.address,
            contentsManager.address,
            accountManager.address
        ).should.be.fulfilled;

        apiContents = await ApiContents.new(council.address, {from: owner});

        await council.initialApiAddress(
            apiContents.address,
            apiContents.address,
            apiContents.address
        ).should.be.fulfilled;

        await token.mint(initialBalance, {from:owner}).should.be.fulfilled;
        await token.unlock({from: owner}).should.be.fulfilled;
        await token.transfer(accountManager.address, 100000 * decimals, {from: owner}).should.be.fulfilled;
    });

    describe("Test api contents.", () => {
        it("Create new account.", async () => {

            let writerBalance = await token.balanceOf.call(writer, {from: writer});
            let user1Balance = await token.balanceOf.call(user1, {from: user1});
            let user2Balance = await token.balanceOf.call(user2, {from: user2});

            writerBalance.should.be.bignumber.equal(0);
            user1Balance.should.be.bignumber.equal(0);
            user2Balance.should.be.bignumber.equal(0);

            await accountManager.createNewAccount(
                "writer",
                "qwer1234",
                "asdfasdfasdfasdf",
                writer,
                {from: writer}
            ).should.be.fulfilled;

            await accountManager.createNewAccount(
                "user1",
                "qwer1234",
                "asdfasdfasdfasdf",
                user1,
                {from: user1}
            ).should.be.fulfilled;

            await accountManager.createNewAccount(
                "user2",
                "qwer1234",
                "asdfasdfasdfasdf",
                user2,
                {from: user2}
            ).should.be.fulfilled;

            writerBalance = await token.balanceOf.call(writer, {from: writer});
            user1Balance = await token.balanceOf.call(user1, {from: user1});
            user2Balance = await token.balanceOf.call(user2, {from: user2});

            writerBalance.should.be.bignumber.equal(airdropAmount);
            user1Balance.should.be.bignumber.equal(airdropAmount);
            user2Balance.should.be.bignumber.equal(airdropAmount);

            let _isRegisterd = await accountManager.isRegistered.call("writer", {from:writer});
            _isRegisterd.should.be.equal(true);
            _isRegisterd = await accountManager.isRegistered.call("user1", {from:user1});
            _isRegisterd.should.be.equal(true);
            _isRegisterd = await accountManager.isRegistered.call("user2", {from:user2});
            _isRegisterd.should.be.equal(true);
        });

        it("Transfer initial deposit.", async () => {
            const _toAddress = await council.getContentsManager.call({from: writer});

            await token.approveAndCall(_toAddress, initialDeposit, "", {from: writer});

            const _initialDeposit = await apiContents.getInitialDeposit.call(writer, {from: writer});

            _initialDeposit.should.be.bignumber.equal(initialDeposit);
        });

        it("Add contents.", async () => {
            await apiContents.addContents(record, 10 * decimals, {from:writer});

            const _contentsAddress = await apiContents.getContentsAddress.call(writer, {from:writer});
            _contentsAddress.length.should.be.equal(1);

            const _contentsRecords = await apiContents.getContentsRecord.call(_contentsAddress, {from: writer});
            const _resultAddress = _contentsRecords[0];
            const _record = _contentsRecords[1];
            const _startIndex = _contentsRecords[2];
            const _endIndex = _contentsRecords[3];

            _resultAddress.length.should.be.equal(1);
            _startIndex.length.should.be.equal(1);
            _endIndex.length.should.be.equal(1);

            _resultAddress[0].should.be.equal(_contentsAddress[0]);
            _startIndex.length.should.be.equal(_endIndex.length);

            var _arrayAddress = [];
            for(var i = 0; i < _startIndex.length ; i++) {
                _arrayAddress[i] = _resultAddress[i].substring(_startIndex[i], _endIndex[i]);
            }

            _contentsAddress.length.should.be.equal(_arrayAddress.length);
            for(var j = 0; j < _arrayAddress.length ; j++) {
                _arrayAddress[j].should.be.equal(_contentsAddress[j]);
            }
        });

        it("Update contents record.", async () => {
            const _contentsDetail = await apiContents.getWriterContentsList.call(writer, {from: writer});
            const _contentsAddress = _contentsDetail[0];
            const _originalRecord = _contentsDetail[1];
            const _originalSIndex = _contentsDetail[2];
            const _originalEIndex = _contentsDetail[3];
            _contentsAddress.length.should.be.equal(1);
            record.should.be.equal(web3.toUtf8(_originalRecord.substring(_originalSIndex[0], _originalEIndex[0])));

            await apiContents.updateContent(_contentsAddress[0], updateRecord, marketerRate, {from:writer});

            const _updateContentsDetail = await apiContents.getWriterContentsList.call(writer, {from: writer});
            const _updateContentsAddress = _updateContentsDetail[0];
            const _updateRecord = _updateContentsDetail[1];
            const _updateSIndex = _updateContentsDetail[2];
            const _updateEIndex = _updateContentsDetail[3];

            _updateSIndex.length.should.be.equal(_updateEIndex.length);
            _updateContentsAddress[0].should.be.equal(_contentsAddress[0]);

            var _arrayRecord = [];
            for(var i = 0; i < _updateSIndex.length ; i++) {
                _arrayRecord[i] = web3.toUtf8(_updateRecord.substring(_updateSIndex[i], _updateEIndex[i]));
            }
            _arrayRecord.length.should.be.equal(1);

            for(var j = 0; j < _arrayRecord.length ; j++) {
                _arrayRecord[j].should.be.equal(updateRecord);
            }
        });

        it("Add episode.", async () => {
            const episodePrice = 10 * decimals;

            const _contentsDetail = await apiContents.getWriterContentsList.call(writer, {from: writer});
            const _contentsAddress = _contentsDetail[0][0];
            const _originalRecord = _contentsDetail[1];
            const _originalSIndex = _contentsDetail[2];
            const _originalEIndex = _contentsDetail[3];

            await apiContents.addEpisode(_contentsAddress, episode, imageUrl, episodePrice, {from: owner}).should.be.rejected;
            await apiContents.addEpisode(_contentsAddress, episode, imageUrl, episodePrice, {from: writer}).should.be.fulfilled;

            const _episodeDetail = await apiContents.getEpisodeFullList(_contentsAddress, {from: writer});
            const _episodeRecord = _episodeDetail[0];
            const _episodeSIndex = _episodeDetail[1];
            const _episodeEIndex = _episodeDetail[2];
            const _episodePrice = _episodeDetail[3];
            const _episodeBuyCount = _episodeDetail[4];
            const _episodePurchased = _episodeDetail[5];

            _episodeSIndex.length.should.be.equal(1);
            _episodeSIndex.length.should.be.equal(_episodeEIndex.length);
            _episodePrice.length.should.be.equal(_episodeBuyCount.length);
            _episodeSIndex.length.should.be.equal(_episodePurchased.length);

            episode.should.be.equal(web3.toUtf8(_episodeRecord.substring(_episodeSIndex[0], _episodeEIndex[0])));
            episodePrice.should.be.equal(_episodePrice[0].toNumber())
            _episodeBuyCount[0].toNumber().should.be.equal(0);
            _episodePurchased[0].should.be.equal(true);
        });

        it("Update episode.", async () => {
            const episodePrice = 10 * decimals;
            const strEpisode = "update episode";

            const _contentsDetail = await apiContents.getWriterContentsList.call(writer, {from: writer});
            const _contentsAddress = _contentsDetail[0][0];

            await apiContents.updateEpisode(_contentsAddress, 0, episode, imageUrl, episodePrice, {from: owner}).should.be.rejected;

            await apiContents.updateEpisode(_contentsAddress, 0, strEpisode, imageUrl, episodePrice, {from: writer}).should.be.fulfilled;

            const _episodeDetail = await apiContents.getEpisodeFullList(_contentsAddress, {from: writer});
            const _episodeRecord = _episodeDetail[0];
            const _episodeSIndex = _episodeDetail[1];
            const _episodeEIndex = _episodeDetail[2];
            const _episodePrice = _episodeDetail[3];
            const _episodeBuyCount = _episodeDetail[4];
            const _episodePurchased = _episodeDetail[5];

            _episodeSIndex.length.should.be.equal(1);

            strEpisode.should.be.equal(web3.toUtf8(_episodeRecord.substring(_episodeSIndex[0], _episodeEIndex[0])));
        });

        it("Pick count test.", async () => {
            const _contentsDetail = await apiContents.getWriterContentsList.call(writer, {from: writer});
            const _contentsAddress = _contentsDetail[0][0];

            let pickCount = await apiContents.getPickCount(_contentsAddress, {from: owner});
            pickCount.toNumber().should.be.equal(0);

            await apiContents.addPickCount(_contentsAddress, {from: owner});
            pickCount = await apiContents.getPickCount(_contentsAddress, {from: owner});
            pickCount.toNumber().should.be.equal(1);
        });
    });
});
