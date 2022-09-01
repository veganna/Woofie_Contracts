const Perks = artifacts.require("Perks");
const Usdc = artifacts.require("USDC");
const Woofiepup = artifacts.require("WOOFIEPUPChihuahua");

module.exports = async function(deployer, network, accounts) {
    if (network == 'test') {
        await deployer.deploy(Perks, 100000, accounts[3], accounts[4], accounts[5]);
        await deployer.deploy(Usdc, 100000);
        const usdcAddress = await Usdc.address;
        const woofieAddress = await Perks.address;
        await deployer.deploy(Woofiepup, usdcAddress, woofieAddress, accounts[5]);

    }else{
        const woofieToken = deployer.deploy(Perks, 100000000000, "0xd988DF0856BB9A3B308d3c19959917e21D6d3150", "0xF7D478F6F929CDd53dcD98b6C63570A54365abAD", "0xFEa1c38441880Ba849e2eD23000F26022f894201");
    }
}