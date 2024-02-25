const { ethers } = require("hardhat");
const { deployContract, contractAt, sendTxn, getFrameSigner } = require("../shared/helpers")
const { getDeployFilteredInfo } = require("../shared/syncParams");

async function deployTokenContract() {

    const accounts = await hre.ethers.getSigners()
    // await deployContract ("WBTC", [], "WBTC");
    // const wbtcToken = await contractAt("WBTC", getDeployFilteredInfo("WBTC").imple)
    // await sendTxn(wbtcToken.authorize("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3"), "WBTC token authorized")
    // await sendTxn(wbtcToken.mint("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3", "10000000000000"), "WBTC token minting")
 
    // await deployContract ("BMMPresale", ["0x78dEca24CBa286C0f8d56370f5406B48cFCE2f86", "0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3"], "BMMPresale");
    
    let tokenContract;
    if (getDeployFilteredInfo("TaxToken")) {
        tokenContract = await contractAt ("TaxToken", getDeployFilteredInfo("TaxToken").imple)
    } else {
        tokenContract = await deployContract ("TaxToken", [], "TaxToken");
    }

    const router = await ethers.getContractAt("IPulseXRouter02", "0x165C3410fC91EF562C50559f7d2289fEbed552d9")

    console.log ("WPLS ===>", await router.WPLS())
    console.log ("accounts[0] ===>", accounts[0].address)

    await sendTxn (tokenContract.transfer ("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3", "1000000000000000000000"), "Token transfer")

    // await sendTxn(router.addLiquidity(
    //     getDeployFilteredInfo("TaxToken").imple,
    //     await router.WPLS(),
    //     100,
    //     1000,
    //     0,
    //     0,
    //     accounts[0].address,
    //     parseInt(new Date() / 1000) + 1000
    // ), "Router addLiquidity")
    
    // const usdtToken = await contractAt("BMM", getDeployFilteredInfo("USDT").imple)
    // await sendTxn(usdtToken.authorize("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3"), "USDT token authorized")
    // await sendTxn(usdtToken.mint("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3", "100000000000"), "USDT token minting")
    
    // await deployContract ("USDC", [], "USDC");
    // const usdcToken = await contractAt("USDC", getDeployFilteredInfo("USDC").imple)
    // await sendTxn(usdcToken.authorize("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3"), "USDC token authorized")
    // await sendTxn(usdcToken.mint("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3", "100000000000"), "USDC token minting")
    
    // await deployContract ("UNI", [], "UNI");
    // const uniToken = await contractAt("UNI", getDeployFilteredInfo("UNI").imple)
    // await sendTxn(uniToken.authorize("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3"), "UNI token authorized")
    // await sendTxn(uniToken.mint("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3", "100000000000000000000000"), "UNI token minting")
    
    // await deployContract ("DAI", [], "DAI");
    // const daiToken = await contractAt("DAI", getDeployFilteredInfo("DAI").imple)
    // await sendTxn(daiToken.authorize("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3"), "DAI token authorized")
    // await sendTxn(daiToken.mint("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3", "100000000000000000000000"), "DAI token minting")
    
    // await deployContract ("Frax", [], "Frax");
    // const fraxToken = await contractAt("Frax", getDeployFilteredInfo("Frax").imple)
    // await sendTxn(fraxToken.authorize("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3"), "Frax token authorized")
    // await sendTxn(fraxToken.mint("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3", "100000000000000000000000"), "Frax token minting")

    // await deployContract ("LINK", [], "LINK");
    // const linkToken = await contractAt("LINK", getDeployFilteredInfo("LINK").imple)
    // await sendTxn(linkToken.authorize("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3"), "LINK token authorized")
    // await sendTxn(linkToken.mint("0x42d0b8efF2fFF1a70B57C8E96bE77C2e49A774c3", "100000000000000000000000"), "LINK token minting")
}

module.exports = deployTokenContract