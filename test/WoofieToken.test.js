const WoofieToken = artifacts.require('Perks');
const Usdc = artifacts.require('USDC');
const Woofiepup = artifacts.require("WOOFIEPUPChihuahua");

contract('WoofieToken', (accounts) => {
    it("should be Woofie Token", async () => {
        const token = await WoofieToken.deployed();
        const name = await token.name();
        assert.equal(name, 'Woofie Token');
    })

    it("should be able to transfer tokens", async () => {
        const token = await WoofieToken.deployed();
        await token.transfer(accounts[1], 100);
        const balance = await token.balanceOf(accounts[1]);
        assert.equal(balance.toNumber(), 95);
    })

    it("should define golden hour", async () => {
        const token = await WoofieToken.deployed();
        await token.setGoldenHour();
        const goldenHour = await token.isGoldenHour();
        assert.equal(goldenHour, true);
    })

    it("should be able to transfer tokens from another account", async () => {
        const token = await WoofieToken.deployed();
        await token.transfer(accounts[2], 100, {from: accounts[0]});
        const balance = await token.balanceOf(accounts[2]);
        assert.equal(balance.toNumber(), 100);
    })

    it("should turn golden hour down", async () =>{
        setTimeout(async () => {
            const token = await WoofieToken.deployed();
            assert.equal(token.isGoldenHour(), false);
        } , 3600000);
    })

    it("should return account 3 as wormhole account", async () => {
        const token = await WoofieToken.deployed();
        const wormhole = await token.wormholeAddress();
        assert.equal(wormhole, accounts[3]);
    })

    it("should return account 4 as marketing account", async () => {
        const token = await WoofieToken.deployed();
        const wormhole = await token.marketingAddress();
        assert.equal(wormhole, accounts[4]);
    })

    it("should return account 5 as treasure donation account", async () => {
        const token = await WoofieToken.deployed();
        const wormhole = await token.treasureDonationAddress();
        assert.equal(wormhole, accounts[5]);
    })

    it("should return 18 decimals", async () => {
        const token = await WoofieToken.deployed();
        const decimals = await token.decimals();
        assert.equal(decimals, 18);
    })

    it("should send 1% of every transaction to wormhole", async () => {
        const token = await WoofieToken.deployed();
        await token.transfer(accounts[1], 100, {from: accounts[0]});
        const balance = await token.balanceOf(accounts[3]);
        assert.equal(balance.toNumber(), 1);
    })

    it("should send 2% of every transaction to marketing", async () => {
        const token = await WoofieToken.deployed();
        const balance = await token.balanceOf(accounts[4]);
        assert.equal(balance.toNumber(), 2);
    })

    it("should send 2% of every transaction to treasure donation", async () => {
        const token = await WoofieToken.deployed();
        const balance = await token.balanceOf(accounts[5]);
        assert.equal(balance.toNumber(), 2);
    })

})

contract('USDC', (accounts) =>{
    it("should be USDC", async () => {
        const token = await Usdc.deployed();
        const name = await token.name();
        assert.equal(name, 'USD Coin');
    })

    it("should be able to transfer tokens", async () => {
        const token = await Usdc.deployed();
        await token.transfer(accounts[1], 300*10**6);
        const balance = await token.balanceOf(accounts[1]);
        assert.equal(balance.toNumber(), 300*10**6);
    })

    it("should be able to transfer tokens from another account", async () => {
        const token = await Usdc.deployed();
        await token.transfer(accounts[2], 300*10**6, {from: accounts[0]});
        const balance = await token.balanceOf(accounts[2]);
        assert.equal(balance.toNumber(), 300*10**6);
    })

    it("should return 6 decimals", async () => {
        const token = await Usdc.deployed();
        const decimals = await token.decimals();
        assert.equal(decimals, 6);
    })
})

contract('Woofiepup', (accounts) => {
    it("should be able to mint with USDC", async () =>{
        const token = await Woofiepup.deployed();
        const usdc = await Usdc.deployed();
        //mint 1 token for msg.value = 200 USDC
        await usdc.approve(token.address, 200*10**6);
        await token.mint(accounts[0], {from: accounts[0], value: 200*10**6});
        const balance = await token.balanceOf(accounts[0]);
        assert.equal(balance, 1);
    })

    it("should send 50% to treasure donation", async () => {
        const token = await Woofiepup.deployed();
        const usdc = await Usdc.deployed();
        const balance = await usdc.balanceOf(accounts[5]);
        assert.equal(balance.toNumber(), 100*10**6);
        
    })

    it("should be able to transfer", async () =>{
        const token = await Woofiepup.deployed();
        await token.approve(accounts[1], 1);
        await token.transferFrom(accounts[0], accounts[1], 1);
        const balance = await token.balanceOf(accounts[1]);
        assert.equal(balance, 1);
    })

    it("should be able to pay the monthly fees", async () => {
        const token = await Woofiepup.deployed();
        const usdc = await Usdc.deployed();
        await usdc.transfer(accounts[1], 100*10**6, {from: accounts[0]});
        await usdc.approve(token.address, 25*10**5, {from: accounts[1]});
        await token.monthlyFeeCollector({from: accounts[1], value: 25*10**7});
        const isActive = await token._MonthlyIsActive(accounts[1], {from: accounts[1]});
        assert.equal(isActive, true);
    })

    it("should define 1.17% of daily reward", async () =>{
        const token = await Woofiepup.deployed();
        const usdc = await Usdc.deployed();
        await usdc.transfer(accounts[2], 300*10**6, {from:accounts[0]})
        await usdc.approve(token.address, 200*10**6, {from:accounts[2]})
        await token.mint(accounts[2], {from: accounts[2], value: 200*10**6});
        const rewardBalance = await token.getReward(accounts[1]);
        assert.equal(rewardBalance, 1)

    })
})