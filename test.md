启动测试节点
```
<!-- 创建100个测试地址 -->
ganache-cli  -l 80000000000 --allowUnlimitedContractSize --hardfork muirGlacier -i 5777 -a 100

truffle test --show-events


//部署到测试网
truffle migrate --network ropsten

truffle migrate --network kovan

//部署到本地
truffle migrate --network development
```
