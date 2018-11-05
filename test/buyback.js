const Buyback = artifacts.require("Buyback")
const TokenGNO = artifacts.require('TokenGNO')
const EtherToken = artifacts.require("EtherToken")
const DutchExchangeProxy = artifacts.require("DutchExchangeProxy")
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545")) // Hardcoded development port

contract("Buyback", accounts => {
      
    let BuyBackAccount, SecondAccount, buyBack, etherToken, dxProxy, tokenGNO;

    BuyBackAccount = accounts[0]
    SecondAccount = accounts[1]


    before (async() => {
        dxProxy = await DutchExchangeProxy.deployed()
        tokenGNO = await TokenGNO.deployed()
        etherToken = await EtherToken.deployed()

        buyBack = await Buyback.new(dxProxy.address, tokenGNO.address, etherToken.address, true, [1,2,3], [1e18, 1e18, 1e18], {from: BuyBackAccount})
    })

    describe("Test Buyback Implementation", async() => {
        it("Should deposit tokens", async() => {
            // approve the buy back contract address to withdraw 1e18 tokens from etherToken
            console.log(`buyback address ${buyBack.address}`)
            let transfer = await etherToken.de(SecondAccount, 20e18, {from: BuyBackAccount})
            console.log({transfer})
            let approve = await etherToken.approve(buyBack.address, 20e18, {from: BuyBackAccount})
            console.log({approve})
            let result = await etherToken.balanceOf(BuyBackAccount)
            result = result.toNumber() / 10e18
            console.log({result})
            let tx = await buyBack.deposit(etherToken.address, 10e18, {from: BuyBackAccount})
            console.log(tx)
        })
    })
})