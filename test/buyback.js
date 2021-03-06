const Buyback = artifacts.require("Buyback")
const TokenGNO = artifacts.require('TokenGNO')
const EtherToken = artifacts.require("EtherToken")
const DutchExchangeProxy = artifacts.require("DutchExchangeProxy")

const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545")) // Hardcoded development port

contract("Buyback", accounts => {
      
    let BuyBackAccount, SecondAccount, buyBack, etherToken, dxProxy, tokenGNO, SecondBurnAddress;

    BuyBackAccount = accounts[0]
    SecondAccount = accounts[1]
    BurnAddress = accounts[3]
    SecondBurnAddress = accounts[2]



    before (async() => {
        dxProxy = await DutchExchangeProxy.deployed()
        tokenGNO = await TokenGNO.deployed()
        etherToken = await EtherToken.deployed()
    })

    describe("Test Buyback Implementation", async() => {
        
        it("Should create contract", async() => {
            buyBack = await Buyback.new(dxProxy.address, tokenGNO.address, etherToken.address, BurnAddress, true, [1,2,3], [1e18, 1e18, 1e18], {from: BuyBackAccount})
        })

        it("Should deposit tokens", async() => {
            // approve the buy back contract address to withdraw 1e18 tokens from etherToken
            await etherToken.deposit({from: BuyBackAccount, value: 20e18 })
            await etherToken.approve(buyBack.address, 20e18, {from: BuyBackAccount})
            await etherToken.balanceOf(BuyBackAccount)
            await buyBack.deposit(etherToken.address, 10e18, {from: BuyBackAccount})
        })

        it("Should prevent deposit with amount 0", async() => {
            // approve the buy back contract address to withdraw 1e18 tokens from etherToken
            let errorThrown = false
            try {
                await buyBack.deposit(etherToken.address, 0, {from: BuyBackAccount})
            } catch(e) {
                errorThrown = true
            }
            assert.ok(errorThrown, "Should prevent deposit with amount 0");
        })

        it("Should prevent deposit of tokens different from the sell token", async() => {
            // approve the buy back contract address to withdraw 1e18 tokens from etherToken
            let errorThrown = false
            try {
                await buyBack.deposit(tokenGNO.address, 10e18, {from: BuyBackAccount})
            } catch(e) {
                errorThrown = true
            }
            assert.ok(errorThrown, "Should prevent deposit with amount 0");
        })

        const auctionIndexes = [1, 2, 3] 
        const auctionAmounts = [1e17, 1e19, 1e18]

        it("Should allow modification of auction amount & index", async () => {
           
            await buyBack.modifyAuctionsMulti(auctionIndexes, auctionAmounts)
        })

        it("Should prevent modifying auction with invalid length", async() => {
            let errorThrown = false
            try {
                let auctionIndexes = [1,2,3,4] 
                let auctionAmounts =  [1e17, 1e19]
                await buyBack.modifyAuctionsMulti(auctionIndexes, auctionAmounts)
            } catch(e) {
                errorThrown = true
            }
            assert.ok(errorThrown, "Should prevent modifying auction with invalid length");
        })

        it("Should prevent modifying auction with empty array", async() => {
            let errorThrown = false
            try {
                let auctionIndexes = [] 
                let auctionAmounts =  [1e17, 1e19]
                await buyBack.modifyAuctionsMulti(auctionIndexes, auctionAmounts)
            } catch(e) {
                errorThrown = true
            }
            assert.ok(errorThrown, "Should prevent modifying auction with invalid length");
        })

        it("Should get all the created auction indexes", async() => {
            const result = await buyBack.getAuctionIndexes({from: BuyBackAccount});

            assert.equal(result[0].toNumber(), auctionIndexes[0], "Invalid details")
            assert.equal(result[1].toNumber(), auctionIndexes[1], "Invalid details")
            assert.equal(result[2].toNumber(), auctionIndexes[2], "Invalid details")
        })

        it("Should get the auction amount with auction index", async() => {
            for(let index in auctionIndexes) {
                const result = await buyBack.getAuctionAmount(auctionIndexes[index], {from: BuyBackAccount});
                assert.equal(result.toNumber(), auctionAmounts[index], "Invalid details")
            }
        })

        it("Should delete an auction using auction index if its not pariticipated in ", async() => {
            const result = await buyBack.deleteAuction(0, {from: BuyBackAccount});

            assert.equal(result.logs[0].args.auctionIndex, auctionIndexes[0], "Failed to delete auction using index")
            assert.equal(result.logs[0].args.amount, auctionAmounts[0], "Failed to delete auction using index")
        })

        it("Should delete multiple auction amount with auction index", async() => {
            const result = await buyBack.deleteAuctionMulti([0, 0], {from: BuyBackAccount});
            let i = 1
            for(let log of result.logs){
                assert.equal(log.args.auctionIndex, auctionIndexes[i], "Failed to delete auction using index")
                assert.equal(log.args.amount, auctionAmounts[i], "Failed to delete auction using index")
                i++
            }
        })

        it("Should prevent deleting multiple auction with empty array", async() => {
            let errorThrown = false
            try {
                await buyBack.deleteAuctionMulti([], {from: BuyBackAccount});
            } catch(e) {
                errorThrown = true
            }
            assert.ok(errorThrown, "Should prevent deleting auction with invalid length");
        });

        it("Should allow to get burn address", async() => {
            const address = await buyBack.getBurnAddress({from: BuyBackAccount});
            assert.equal(address, BurnAddress, "Invalid burn addresses")
        });

        it("Should allow to modify burn", async() => {
            await buyBack.modifyBurn(true, {from: BuyBackAccount});
        });

        it("Should allow to modify burn address", async() => {
            await buyBack.modifyBurnAddress(SecondBurnAddress, {from: BuyBackAccount});
            const address = await buyBack.getBurnAddress({from: BuyBackAccount});
            assert.equal(address, SecondBurnAddress, "Invalid burn addresses")
        });

        it("Should allow to pariticipate")

    })
})