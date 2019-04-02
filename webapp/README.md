请记得打开ca-server
```shell
docker-compose -f ../network/docker-compose-ca.yaml up -d
```
```shell
npm install
```
```shell
node enrollAdmin

node registerUser.js
```
```shell
nohup node index.js &
```
see http:// localhost:3000
