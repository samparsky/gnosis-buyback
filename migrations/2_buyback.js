var Buyback = artifacts.require("./Buyback.sol");

module.exports = function(deployer) {
    deployer.deploy(Buyback);
}