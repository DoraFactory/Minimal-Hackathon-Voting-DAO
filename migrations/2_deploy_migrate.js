const BigNumber = require('bignumber.js');
const TokenDemo = artifacts.require("TokenDemo");
const DAO = artifacts.require("DAO");



module.exports = function (deployer, network, accounts) {
    console.log("network: ", network);
    deployer.then(async () => {
        this.TokenDemo1 = await deployer.deploy(TokenDemo);
        this.TokenDemo2 = await deployer.deploy(TokenDemo);
        this.DAO = await deployer.deploy(DAO);
    });
};


