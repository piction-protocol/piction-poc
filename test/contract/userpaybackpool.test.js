var Pxl = artifacts.require("PXL");
var Council = artifacts.require("Council");
var UserPaybackPool = artifacts.require("UserPaybackPool");
var RoleManager = artifacts.require("RoleManager");

const BigNumber = web3.BigNumber;

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("UserPaybackPool", (accounts) => {
    const owner = accounts[0];
    const pxlDistributor = accounts[1];

    const users = accounts.slice(2, 7);

    const decimals = Math.pow(10, 18);
    const initialBalance = new BigNumber(100000 * decimals);
    const initialUserBalance = new BigNumber(100 * decimals);

    let token;
    let council;
    let userPaybackPool;
    let roleManager;

    beforeEach("Setup contract", async () => {
        token = await Pxl.new(initialBalance, {from: owner});
        council = await Council.new(token.address, {from: owner});
        userPaybackPool = await UserPaybackPool.new(council.address, 1 / 86400, {from: owner});
        roleManager = await RoleManager.new({from: owner});

        await roleManager.addAddressToRole(pxlDistributor, "PXL_DISTRIBUTOR", {from: owner});
        await council.setRoleManager(roleManager.address, {from: owner});

        await token.unlock({from: owner});

        await token.transfer(pxlDistributor, initialUserBalance, {from: owner});

        users.forEach( async (user) => {
            await token.transfer(user, initialUserBalance, {from: owner});
        });
    });

    describe("AddPayback", () => {
        it("add Payback a user.", async () => {
            const purchaseAmount = new BigNumber(2 * decimals);
            const user = users[0];

            await token.approveAndCall(userPaybackPool.address, purchaseAmount, String(user), {from: pxlDistributor}).should.be.fulfilled;

            const paybackInfoUser = await userPaybackPool.getPaybackInfo.call({from: user}).should.be.fulfilled;

            const poolIndex = paybackInfoUser[0][0];
            const paybackUser = paybackInfoUser[1][0];
            const paybackAmount = paybackInfoUser[2][0];
            const released = paybackInfoUser[3][0];

            poolIndex.should.be.bignumber.equal(0);
            paybackUser.should.be.equal(user);
            paybackAmount.should.be.bignumber.equal(purchaseAmount);
            released.should.be.equal(false);
        });

        it("add Payback many users.", async () => {
            const purchaseAmount = new BigNumber(2 * decimals);

            users.forEach( async (user) => {
                await token.approveAndCall(userPaybackPool.address, purchaseAmount, String(user), {from: pxlDistributor}).should.be.fulfilled;
            });

            users.forEach( async (user, i) => {
                const paybackInfoUser = await userPaybackPool.getPaybackInfo.call({from: user}).should.be.fulfilled;

                console.log(paybackInfoUser)

                const poolIndex = paybackInfoUser[0][0];
                const userAddress = paybackInfoUser[1][0];
                const paybackAmount = paybackInfoUser[2][0];
                const released = paybackInfoUser[3][0];

                poolIndex.should.be.bignumber.equal(0);
                userAddress.should.be.equal(user);
                paybackAmount.should.be.bignumber.equal(purchaseAmount);
                released.should.be.equal(false);
            });
        });

        it("add Payback duplicate user in same pool", async () => {
            const purchaseAmount = new BigNumber(2 * decimals);
            const user = users[0];

            await token.approveAndCall(userPaybackPool.address, purchaseAmount, String(user), {from: pxlDistributor}).should.be.fulfilled;
            await token.approveAndCall(userPaybackPool.address, purchaseAmount, String(user), {from: pxlDistributor}).should.be.fulfilled;

            const paybackInfoUser = await userPaybackPool.getPaybackInfo.call({from: user}).should.be.fulfilled;

            const poolIndex = paybackInfoUser[0][0];
            const paybackUser = paybackInfoUser[1][0];
            const paybackAmount = paybackInfoUser[2][0];
            const released = paybackInfoUser[3][0];

            poolIndex.should.be.bignumber.equal(0);
            paybackUser.should.be.equal(user);
            paybackAmount.should.be.bignumber.equal(purchaseAmount * 2);
            released.should.be.equal(false);
        });

        // it("add Payback next pool", async () => {
        //     const purchaseAmount = new BigNumber(2 * decimals);
        //     const user = users[0];
        //
        //     await token.approveAndCall(userPaybackPool.address, purchaseAmount, String(user), {from: pxlDistributor}).should.be.fulfilled;
        //
        //     setTimeout( async() => {
        //         await token.approveAndCall(userPaybackPool.address, purchaseAmount, String(user), {from: pxlDistributor}).should.be.fulfilled;
        //
        //         const paybackInfoUser = await userPaybackPool.getPaybackInfo.call({from: user}).should.be.fulfilled;
        //         console.log(paybackInfoUser)
        //         console.log(paybackInfoUser.length) // 2
        //
        //         paybackInfoUser.forEach( (info, i) => {
        //             const poolIndex = paybackInfoUser[0][i];
        //             const userAddress = paybackInfoUser[1][i];
        //             const paybackAmount = paybackInfoUser[2][i];
        //             const released = paybackInfoUser[3][i];
        //
        //             poolIndex.should.be.bignumber.equal(i);
        //             userAddress.should.be.equal(user);
        //             paybackAmount.should.be.bignumber.equal(purchaseAmount);
        //             released.should.be.equal(false);
        //         });
        //     }, 2000);
        // });
    });

    describe("Release", () => {

    });
});
