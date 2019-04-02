请记得打开ca-server
docker-compose -f ../network/docker-compose-ca.yaml up -d

npm install

node enrollAdmin

node registerUser.js

nohup node index.js &

see http:// localhost:3000
