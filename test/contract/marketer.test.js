const Marketer = artifacts.require("Marketer");

const BigNumber = web3.BigNumber;

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();


contract("Marketer", function (accounts) {
    const owner = accounts[0];
    const marketerUser = accounts[1];

    const decimals = Math.pow(10, 18);

    let marketer;

    beforeEach("Setup contract", async () => {
        marketer = await Marketer.new({from: owner});
    });

    it("generate marketerKey and check the key.", async () => {
        const marketerKey = await marketer.generateMarketerKey.call({from: marketerUser});
        await marketer.setMarketerKey(marketerKey, {from: marketerUser});

        const marketerAddress = await marketer.getMarketerAddress.call(marketerKey, {from: owner});
        marketerAddress.should.be.equal(marketerUser);
    });
});
