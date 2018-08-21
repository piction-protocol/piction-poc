var Test = artifacts.require("Test");

const BigNumber = web3.BigNumber;

require("chai")
.use(require("chai-as-promised"))
.use(require("chai-bignumber")(BigNumber))
.should();

contract("Test", function (accounts) {
    const owner = accounts[0];
    const userOne = accounts[1];
    const userTwo = accounts[2];
    const userThree = accounts[3];

    const decimals = Math.pow(10, 18);
    const amount = 100 * decimals;

    let test;

    before("Contract initial setup", async() => {
        test = await Test.new({from: owner});
    });

    describe("Test it", () => {
        it("it", async () => {
            console.log("------------------------")
            console.log(userOne)
            console.log(userTwo)
            console.log(userThree)
            console.log(amount)
            console.log("------------------------")
            const result = await test.testAddress.call(userOne, userTwo, userThree, amount, {from: owner});
            console.log(result);
            console.log(result[0]);
            console.log(result[1]);
            console.log(result[2]);
            console.log(result[3]);
            console.log(result[4].toNumber());
        });
    });
});
