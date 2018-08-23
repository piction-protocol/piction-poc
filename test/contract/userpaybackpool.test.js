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
    const deploy = accounts[10];

    const users = accounts.slice(2, 7);


    const decimals = Math.pow(10, 18);
    const initialBalance = new BigNumber(100000 * decimals);
    const initialUserBalance = new BigNumber(100 * decimals);

    let token;
    let council;
    let userPaybackPool;
    let roleManager;

    let toAddress = function bigNumberToPaddedBytes32(num) {
        var n = num.toString(16).replace(/^0x/, '');
        while (n.length < 40) {
            n = "0" + n;
        }
        return "0x" + n;
    }

    beforeEach("Setup contract", async () => {
        token = await Pxl.new({from: deploy});
        council = await Council.new(token.address, {from: owner});
        userPaybackPool = await UserPaybackPool.new(council.address, 2, {from: owner});
        roleManager = await RoleManager.new({from: owner});

        await roleManager.addAddressToRole(pxlDistributor, "PXL_DISTRIBUTOR", {from: owner});
        await council.setRoleManager(roleManager.address, {from: owner});

        await token.transferOwnership(owner, {from: deploy}).should.be.fulfilled;
        await token.mint(initialBalance, {from: owner}).should.be.fulfilled;

        await token.unlock({from: owner});

        await token.transfer(pxlDistributor, initialUserBalance, {from: owner});

        users.forEach( async (user) => {
            await token.transfer(user, initialUserBalance, {from: owner});
        });
    });

    describe("AddPayback", () => {
        it("add payback for one user.", async () => {
            const purchaseAmount = new BigNumber(2 * decimals);
            const user = users[0];

            await token.approveAndCall(userPaybackPool.address, purchaseAmount, toAddress(user), {from: pxlDistributor}).should.be.fulfilled;

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

        it("add payback for multiple users.", async () => {
            const purchaseAmount = new BigNumber(2 * decimals);

            const addPaybackPromise = new Promise( async (resolve, reject) => {
                users.forEach( async (user) => {
                    await token.approveAndCall(userPaybackPool.address, purchaseAmount, toAddress(user), {from: pxlDistributor}).should.be.fulfilled;
                    resolve();
                });
            });
            await addPaybackPromise;

            users.forEach( async (user, i) => {
                const paybackInfoUser = await userPaybackPool.getPaybackInfo.call({from: user}).should.be.fulfilled;

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

        it("add payback to same pool for same user.", async () => {
            const purchaseAmount = new BigNumber(2 * decimals);
            const user = users[0];

            await token.approveAndCall(userPaybackPool.address, purchaseAmount, toAddress(user), {from: pxlDistributor}).should.be.fulfilled;
            await token.approveAndCall(userPaybackPool.address, purchaseAmount, toAddress(user), {from: pxlDistributor}).should.be.fulfilled;

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

        it("add payback to next pool.", async () => {
            const purchaseAmount = new BigNumber(2 * decimals);
            const user = users[0];

            await token.approveAndCall(userPaybackPool.address, purchaseAmount, toAddress(user), {from: pxlDistributor}).should.be.fulfilled;

            const addPaybackPromise = new Promise( async (resolve, reject) => {
                setTimeout( async() => {
                    await token.approveAndCall(userPaybackPool.address, purchaseAmount, toAddress(user), {from: pxlDistributor}).should.be.fulfilled;
                    const currentIndex = await userPaybackPool.getCurrentIndex.call().should.be.fulfilled;
                    currentIndex.should.be.bignumber.equal(1);

                    const paybackInfoUser = await userPaybackPool.getPaybackInfo.call({from: user}).should.be.fulfilled;

                    paybackInfoUser[0].forEach( (info, i) => {
                        const poolIndex = paybackInfoUser[0][i];
                        const userAddress = paybackInfoUser[1][i];
                        const paybackAmount = paybackInfoUser[2][i];
                        const released = paybackInfoUser[3][i];

                        poolIndex.should.be.bignumber.equal(i);
                        userAddress.should.be.equal(user);
                        paybackAmount.should.be.bignumber.equal(purchaseAmount);
                        released.should.be.equal(false);

                        if (paybackInfoUser[0].length - 1 == i) {
                            resolve();
                        }
                    });
                }, 2000);
            });
            await addPaybackPromise;
        });
    });

    describe("Release", () => {
        beforeEach("Setup payback", async () => {
            const purchaseAmount = new BigNumber(2 * decimals);
            const user = users[0];

            await token.approveAndCall(userPaybackPool.address, purchaseAmount, toAddress(user), {from: pxlDistributor}).should.be.fulfilled;
        });

        it("release by a user", async () => {
            const user = users[0];
            const purchaseAmount = new BigNumber(2 * decimals);

            const beforeBalance = await token.balanceOf(user);

            const releasePromise = new Promise( async (resolve, reject) => {
                setTimeout( async() => {
                    await userPaybackPool.release({from: user}).should.be.fulfilled;

                    resolve();
                }, 2000);
            });
            await releasePromise;

            const paybackInfoUser = await userPaybackPool.getPaybackInfo.call({from: user}).should.be.fulfilled;

            paybackInfoUser[0].forEach( (info, i) => {
                const poolIndex = paybackInfoUser[0][i];
                const userAddress = paybackInfoUser[1][i];
                const paybackAmount = paybackInfoUser[2][i];
                const released = paybackInfoUser[3][i];

                poolIndex.should.be.bignumber.equal(i);
                userAddress.should.be.equal(user);
                paybackAmount.should.be.bignumber.equal(purchaseAmount);
                released.should.be.equal(true);
            });

            const afterBalance = await token.balanceOf(user);
            afterBalance.sub(beforeBalance).should.be.bignumber.equal(purchaseAmount);
        });

        it("release without already released.", async () => {
            const user = users[0];
            const purchaseAmount = new BigNumber(2 * decimals);

            const releasePromise1 = new Promise( async (resolve, reject) => {
                setTimeout( async() => {
                    await userPaybackPool.release({from: user}).should.be.fulfilled;

                    resolve();
                }, 2000);
            });
            await releasePromise1;

            const beforeBalance = await token.balanceOf(user);

            await token.approveAndCall(userPaybackPool.address, purchaseAmount, toAddress(user), {from: pxlDistributor}).should.be.fulfilled;

            const releasePromise2 = new Promise( async (resolve, reject) => {
                setTimeout( async() => {
                    await userPaybackPool.release({from: user}).should.be.fulfilled;

                    resolve();
                }, 2000);
            });
            await releasePromise2;

            const afterBalance = await token.balanceOf(user);
            afterBalance.sub(beforeBalance).should.be.bignumber.equal(purchaseAmount);
        });

        it("release for multiple pool.", async () => {
            const user = users[0];
            const purchaseAmount = new BigNumber(2 * decimals);

            const beforeBalance = await token.balanceOf(user);

            const addPaybackPromise = new Promise( async (resolve, reject) => {
                setTimeout( async() => {
                    await token.approveAndCall(userPaybackPool.address, purchaseAmount, toAddress(user), {from: pxlDistributor}).should.be.fulfilled;

                    resolve();
                }, 2000);
            });
            await addPaybackPromise;

            const currentIndex = await userPaybackPool.getCurrentIndex.call().should.be.fulfilled;
            currentIndex.should.be.bignumber.equal(1);

            const paybackInfoUser = await userPaybackPool.getPaybackInfo.call({from: user}).should.be.fulfilled;

            const paybackInfoPromise = new Promise( async (resolve, reject) => {
                paybackInfoUser[0].forEach( (info, i) => {
                    const poolIndex = paybackInfoUser[0][i];
                    const userAddress = paybackInfoUser[1][i];
                    const paybackAmount = paybackInfoUser[2][i];
                    const released = paybackInfoUser[3][i];

                    poolIndex.should.be.bignumber.equal(i);
                    userAddress.should.be.equal(user);
                    paybackAmount.should.be.bignumber.equal(purchaseAmount);
                    released.should.be.equal(false);

                    if (paybackInfoUser[0].length - 1 == i) {
                        resolve();
                    }
                });
            });
            await paybackInfoPromise;

            const releasePromise = new Promise( async (resolve, reject) => {
                setTimeout( async() => {
                    await userPaybackPool.release({from: user}).should.be.fulfilled;

                    resolve();
                }, 2000);
            });
            await releasePromise;

            const afterBalance = await token.balanceOf(user);
            afterBalance.sub(beforeBalance).should.be.bignumber.equal(purchaseAmount * 2);
        });
    });
});
