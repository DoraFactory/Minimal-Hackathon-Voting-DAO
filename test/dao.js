const BigNumber = require('bignumber.js');
const env = require('./setup.js');
const {expectEvent} = require('@openzeppelin/test-helpers');

contract('deploy contract', (accounts) => {
    before(async function () {
        const artifacts = await env.initContract(accounts[0]);
        Object.assign(this, artifacts);
        this.admin = accounts[0];
        console.log("this.token1.address:", this.token1.address);
        console.log("this.token2.address:", this.token2.address);
        console.log("this.dao.address:", this.dao.address);
    });

    describe('test admin', async function () {
        it('test addJudges', async function () {
            judges = [accounts[1], accounts[2], accounts[3], accounts[4]];
            await this.dao.addJudges(judges);
            res = await this.dao.judges(0);
            assert.equal(res, judges[0]);
            res = await this.dao.getJudges();
            assert.equal(res.toString(), judges);
        });

        it('test supportTokens', async function () {
            tokens = [this.token1.address, this.token2.address];
            await this.dao.supportTokens(tokens);
            res = await this.dao.getSupportTokens();
            assert.equal(res.toString(), tokens);
        });

        it('test regProject and deleteProject', async function () {
            await this.dao.addWhiteList([accounts[0]]);
            projectId = 1;
            name = "test Project";
            result = await this.dao.regProject(name, projectId);
            expectEvent.inLogs(result.logs, 'RegProject', {
                owner: accounts[0],
                name: name,
                projectId: new web3.utils.BN(projectId),
            });
            res = await this.dao.projects(projectId);
            assert.equal(res[0].toString(), projectId);
            assert.equal(res[1].toString(), accounts[0]);
            assert.equal(res[2].toString(), name);
            res = await this.dao.getAllRegisteredIds();
            assert.equal(res.toString(), [1]);

            await this.dao.deleteProject(projectId);
            res = await this.dao.projects(projectId);
            assert.equal(res[0].toString(), 0);
            assert.equal(res[1].toString(), "0x0000000000000000000000000000000000000000");
            assert.equal(res[2].toString(), "");
            res = await this.dao.getAllRegisteredIds();
            assert.equal(res.toString(), []);

            result = await this.dao.regProject(name, projectId);
            expectEvent.inLogs(result.logs, 'RegProject', {
                owner: accounts[0],
                name: name,
                projectId: new web3.utils.BN(projectId),
            });
            res = await this.dao.projects(projectId);
            assert.equal(res[0].toString(), projectId);
            assert.equal(res[1].toString(), accounts[0]);
            assert.equal(res[2].toString(), name);
        });

        it('test vote and end vote', async function () {
            await this.dao.addWhiteList([accounts[1], accounts[2]]);
            projectId = 2;
            name = "test Project2";
            await this.dao.regProject(name, projectId, {from: accounts[1]});

            projectId = 3;
            name = "test Project3";
            await this.dao.regProject(name, projectId, {from: accounts[2]});

            await this.dao.vote([2, 2, 2], {from: accounts[2]});
            res = await this.dao.getVotedInfo(accounts[2]);
            assert.equal(res.toString(), [2, 2, 2]);

            res = await this.dao.projectPoll(2);
            assert.equal(res.toString(), 3);

            await this.token1.transfer(this.dao.address, 1000);
            await this.token2.transfer(this.dao.address, 1000);

            await this.dao.endVote();
            res = await this.dao.getBonus(2);
            assert.equal(res.toString(), [1000, 1000]);

            await this.dao.claimBonus(2, {from: accounts[1]});
            res = await this.dao.getBonus(2);
            assert.equal(res.toString(), [1000, 1000]);
        });
    });
});