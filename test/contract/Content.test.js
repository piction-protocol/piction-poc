const { forEachAsync } = require("../helpers/forEachAsync");

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

contract("Content", function (accounts) {
    const owner = accounts[0];
    const writer = accounts[1];
    const buyusers = accounts.slice(2, 5);
    const testuser = accounts[5];
    const distributor = accounts[6];
    const deploy = accounts[7];

    const decimals = Math.pow(10, 18);
    const initialBalance = new BigNumber(1000000000 * decimals);

    const initialDepositToken = new BigNumber(100 * decimals);
    const episodePrice = new BigNumber(10 * decimals);
    const marketerRate = 10;

    const record = '{"title": "권짱님의 스트레스!!","genres": "액션, 판타지","synopsis": "요괴가 지니고 있는 능력으로 합법적 무력을 행사하고 사회적 문제를 해결하는 단체, \'연옥학원\'. 빼앗긴 심장과 기억을 되찾기 위해 연옥학원에 들어간 좀비, 블루의 모험이 다시 시작된다! 더욱 파워풀한 액션으로 돌아온 연옥학원, 그 두 번째 이야기!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const updateRecord = '{"title": "님명님의 검은사막~~~","genres": "판타지, 성인","synopsis": "매달리던 알바도 짤리고 직업도 없는 채 나이만 먹은 채 30. 이런 나에게 어느 날, 어플 하나로 부자가 될 기회가 찾아왔다. 슈퍼카 건물주 여자 모든 것을 내손에 넣을 수 있다고?","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const episode1 = '{"title": "호롤로로로로님의 게임시간!!!!!","genres": "게임, 일상","synopsis": "여기 이 남자를 보시라! 뭘 해도 어그로 가 끌리는 미친 존재감! 낙천적이며 교활하기 까지한 티이모 유저 제인유와 그의 친구들의 좌충우돌 스토리!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const episode2 = '{"title": "똥쟁이님의 신발 구매???????","genres": "일상","synopsis": "여기 이 남자를 보시라! 뭘 해도 어그로 가 끌리는 미친 존재감! 낙천적이며 교활하기 까지한 티이모 유저 제인유와 그의 친구들의 좌충우돌 스토리!","titleImage": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg","thumbnail": "https://www.battlecomics.co.kr/webtoons/467"}';
    const imageUrl = '{"cuts": "https://www.battlecomics.co.kr/assets/img-logo-692174dc5a66cb2f8a4eae29823bb2b3de2411381f69a187dca62464c6f603ef.svg,https://www.battlecomics.co.kr/webtoons/467"}';

    let token;
    let council;
    let roleManager;
    let depositPool;
    let contentsManager;
    let content;

    before("Initial Setup", async() => {
        token = await PXL.new({from: deploy});
        council = await Council.new(token.address, {from: owner});
        roleManager = await RoleManager.new({from: owner});
        depositPool = await DepositPool.new(council.address, {from: owner});
        contentsManager = await ContentsManager.new(council.address, {from: owner});

        await council.initialValue(initialDepositToken, initialDepositToken, {from: owner}).should.be.fulfilled;
        await council.setRoleManager(roleManager.address, {from: owner}).should.be.fulfilled;
        await council.setDepositPool(depositPool.address, {from: owner}).should.be.fulfilled;
        await roleManager.addAddressToRole(distributor, "PXL_DISTRIBUTOR", {from: owner}).should.be.fulfilled;

        await token.transferOwnership(owner, {from: deploy}).should.be.fulfilled;
        await token.mint(initialBalance, {from: owner}).should.be.fulfilled;
        await token.unlock({from: owner}).should.be.fulfilled;
        await token.transfer(writer, 1000 * decimals, {from: owner}).should.be.fulfilled;
        await token.transfer(testuser, 100 * decimals, {from: owner}).should.be.fulfilled;
        token.transfer(distributor, 500 * decimals, {from: owner}).should.be.fulfilled;

        buyusers.forEach( async(user) => {
            await token.transfer(user, 100 * decimals, {from: owner}).should.be.fulfilled;
        });

    });

    describe("check contents setting", async () => {
        before("create new contents", async() => {
            await token.approveAndCall(
                contentsManager.address,
                initialDepositToken,
                "",
                {from: writer}
            ).should.be.fulfilled;

            await contentsManager.addContents(
                record,
                marketerRate,
                {from: writer}
            ).should.be.fulfilled;

            const writerContents = await contentsManager.getWriterContentsAddress.call(writer, {from: writer});
            content = Content.at(writerContents[0][0]);

            const writerContentAddress = writerContents[0].length;
            const result = writerContents[1];

            writerContentAddress.should.be.bignumber.equal(1);
            result.should.be.equal(true);
        });

        describe("check initial setting", async() => {
            it("compare record", async() => {
                const compareRecord = await content.getRecord.call({from: writer});

                compareRecord.should.be.equal(record);
            });

            it("compare writer", async() => {
                const compareWriter = await content.getWriter.call({from: writer});

                compareWriter.should.be.equal(writer);
            });

            it("compare marketer rate", async() => {
                const marketerRate = await content.getMarketerRate.call({from: writer});

                marketerRate.should.be.bignumber.equal(marketerRate);
            });

            it("compare episode length", async() => {
                const episodeLength = await content.getEpisodeLength.call({from: writer});

                episodeLength.should.be.bignumber.equal(0);
            });
        });

        describe("Update record", async() => {
            it("compare record", async() => {
                await content.updateContent(
                    updateRecord,
                    marketerRate,
                    {from: owner}
                ).should.be.rejected;

                await content.updateContent(
                    updateRecord,
                    marketerRate,
                    {from: writer}
                ).should.be.fulfilled;

                const resultRecord = await content.getRecord.call({from: writer});

                resultRecord.should.be.equal(updateRecord);
            });
        });

        describe("episode test", async() => {
            before("create episode", async() => {
                await content.addEpisode(
                    episode1,
                    imageUrl,
                    episodePrice,
                    {from: writer}
                ).should.be.fulfilled;
            });

            it("check ownable", async() => {
                await content.addEpisode(
                    episode1,
                    imageUrl,
                    episodePrice,
                    {from: owner}
                ).should.be.rejected;

                const empty = await content.getEpisodeCuts.call(0, {from: testuser}).should.be.fulfilled;
                empty.should.be.equal("");

                const episodeLength = await content.getEpisodeLength.call({from: writer});
                const episodeDetail = await content.getEpisodeDetail.call(0, {from: writer});
                const episodeCuts = await content.getEpisodeCuts.call(0, {from: writer});

                 episodeLength.should.be.bignumber.equal(1);
                 episodeDetail[0].should.be.equal(episode1);
                 episodeDetail[1].should.be.bignumber.equal(episodePrice);
                 episodeDetail[2].should.be.bignumber.equal(0);
                 episodeCuts.should.be.equal(imageUrl);
            });

            it("add episode", async() => {
                await content.addEpisode(
                    episode2,
                    imageUrl,
                    episodePrice,
                    {from: writer}
                ).should.be.fulfilled;

                const episodeLength = await content.getEpisodeLength.call({from: writer});
                const episodeDetail = await content.getEpisodeDetail.call(episodeLength - 1, {from: writer});
                const episodeCuts = await content.getEpisodeCuts.call(episodeLength - 1, {from: writer});

                episodeLength.should.be.bignumber.equal(2);
                episodeDetail[0].should.be.equal(episode2);
                episodeDetail[1].should.be.bignumber.equal(episodePrice);
                episodeDetail[2].should.be.bignumber.equal(0);
                episodeCuts.should.be.equal(imageUrl);
            });

            it("episode purchase", async() => {
                const episodeLength = await content.getEpisodeLength.call({from: writer});
                const roleCheck = await roleManager.isAccess.call(distributor, "PXL_DISTRIBUTOR", {from: owner});

                await forEachAsync(buyusers, async (user) => {
                    const isBuying = await content.isPurchasedEpisode.call(episodeLength - 1, user, {from: user});
                    isBuying.should.be.equal(false);

                    await content.episodePurchase(
                        episodeLength - 1,
                        user,
                        episodePrice,
                        {from: distributor}
                    ).should.be.fulfilled;

                    roleCheck.should.be.equal(true);
                });

                const episodeDetail = await content.getEpisodeDetail.call(episodeLength - 1, {from: writer});

                episodeDetail[0].should.be.equal(episode2);
                episodeDetail[1].should.be.bignumber.equal(episodePrice);
                episodeDetail[2].should.be.bignumber.equal(buyusers.length);
            });

            it("get episode image", async () => {
                const episodeLength = await content.getEpisodeLength.call({from: writer});

                const isBuying = await content.isPurchasedEpisode.call(episodeLength - 1, buyusers[0], {from: buyusers[0]});
                isBuying.should.be.equal(true);

                const episodeDetailBuyuserOk = await content.getEpisodeCuts.call(episodeLength - 1, {from: buyusers[0]}).should.be.fulfilled;
                const episodeDetailBuyuserEmpty = await content.getEpisodeCuts.call(episodeLength - 2, {from: buyusers[0]}).should.be.fulfilled;
                const episodeDetailTestuser = await content.getEpisodeCuts.call(episodeLength - 1, {from: testuser}).should.be.fulfilled;

                episodeDetailBuyuserOk.should.be.equal(imageUrl);
                episodeDetailBuyuserEmpty.should.be.equal("");
                episodeDetailTestuser.should.be.equal("");
            });
        });
    });
});
