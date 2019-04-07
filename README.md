# VoteDemo
a demostration of voting system based on hyperledger


| 节点        | 组织   |  端口  |  通道  |
| --------   | -----:  | :----:  | :----:  |
| orderer     | \ |   7050     |   mychannel     |
| peer0        |  org1   |   7051   |   mychannel     |
| peer1        |    org1    |  8051  |   mychannel     |
| peer0     | org2 |   9051     |   mychannel     |
| peer1        |   org2   |   10051   |   mychannel     |



生成公私钥和证书
```shell
cd network/
../bin/cryptogen generate --config=./crypto-config.yaml
```

生成创世区块和通道配置区块
```shell
mkdir channel-artifacts

../bin/configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/mychannel.tx -channelID mychannel
```

打开docker-compose-ca.yaml文件，将
```shell
- FABRIC_CA_SERVER_CA_KEYFILE=/etc/hyperledger/fabric-ca-server-config/dfeaf6c35d81768a1609e528dffb6215040c778fadec79c556096479f1ddfe15_sk
```
修改为./crypto-config/peerOrganizations/org1.example.com/ca/ 文件内xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx_sk文件的名字
```shell
- FABRIC_CA_SERVER_CA_KEYFILE=/etc/hyperledger/fabric-ca-server-config/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx_sk
```

启动网络 所有节点加入Channel
```shell
./net_setup.sh up
```

可用cli命令行操作

```shell
docker exec -it cli bash
```
装载链码 初始化链码 执行链码函数 查询链码函数
```shell
peer chaincode install -n mycc -p github.com/hyperledger/fabric/test/chaincode/go/vote -v 1.0
peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n mycc -v 1.0 -c '{"Args":[]}' -P "OR ('Org1MSP.peer','Org2MSP.peer')"
peer chaincode invoke -C mychannel -n mycc -c '{"Args":["initLedger"]}'
peer chaincode query -C mychannel -n mycc -c '{"Args":["getUserVote"]}'
```
