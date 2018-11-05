const Buyback = artifacts.require("Buyback.sol");
const DutchExchangeProxy = artifacts.require("DutchExchangeProxy")
const EtherToken = artifacts.require("EtherToken")
const GNOToken = artifacts.require("TokenGNO")


module.exports = function(deployer, network, accounts) {
    const BuybackOwnerAccount = accounts[0]

    let dxProxy, etherToken, gnoToken
    console.log("working on deploying")
    return deployer.then(() => {
      dxProxy = DutchExchangeProxy.deployed()
    }).then(() =>{
      etherToken = EtherToken.deployed()
    }).then(() => {
      gnoToken = GNOToken.deployed()
    }).then(() => {
      deployer.deploy(Buyback, dxProxy.address, gnoToken.address, etherToken.address, true, [1,2,3], [1e18, 1e18, 1e18], {from: BuybackOwnerAccount}).then(()=>{})
    })

}