

const TokenDemo = artifacts.require("TokenDemo");
const DAO = artifacts.require("DAO");

module.exports = {
    initContract,
}

async function initContract(admin){
    const token1 = await TokenDemo.new({
        from: admin,
        value: web3.utils.toWei('0', 'ether'),
        gas: 10000000,
        gasPrice: 50
    });
    const token2 = await TokenDemo.new({
        from: admin,
        value: web3.utils.toWei('0', 'ether'),
        gas: 10000000,
        gasPrice: 50
    });
    const dao = await DAO.new({
        from: admin,
        value: web3.utils.toWei('0', 'ether'),
        gas: 10000000,
        gasPrice: 50
    });
    return {token1, token2, dao}
}