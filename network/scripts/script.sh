#!/bin/bash
# Copyright London Stock Exchange Group All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="mychannel"}
: ${TIMEOUT:="60"}
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
PEER0_ORG1_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
PEER0_ORG2_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
ORDERER_SYSCHAN_ID=test-orderer-syschan

echo "Channel name : "$CHANNEL_NAME

verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
                echo "================== ERROR !!! FAILED to execute the scripts =================="
		echo
   		exit 1
	fi
}

setGlobals () {
	PEER=$1
	ORG=$2
	if [ $ORG -eq 1 ] ; then
		CORE_PEER_LOCALMSPID="Org1MSP"
		CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
		if [ $PEER -eq 0 ]; then
			CORE_PEER_ADDRESS=peer0.org1.example.com:7051
		else
			CORE_PEER_ADDRESS=peer1.org1.example.com:7051
		fi
	else
		CORE_PEER_LOCALMSPID="Org2MSP"
		CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
		if [ $PEER -eq 0 ]; then
			CORE_PEER_ADDRESS=peer0.org2.example.com:7051
		else
			CORE_PEER_ADDRESS=peer1.org2.example.com:7051
		fi
	fi

	env |grep CORE
}


createChannel() {
	setGlobals 0 1
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/mychannel.tx >&log.txt
	else
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/mychannel.tx --tls --cafile $ORDERER_CA >log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}


joinChannelWithRetry () {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG

	peer channel join -b $CHANNEL_NAME.block  >log.txt
	res=$?
	cat log.txt
	if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
		COUNTER=` expr $COUNTER + 1`
		echo "peer${PEER}.org${ORG} failed to join the channel, Retry after 1 seconds"
		sleep 1
		joinChannelWithRetry $1
	else
		COUNTER=1
	fi
	verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

joinChannel () {
	for org in 1 2; do
	    for peer in 0 1; do
		    joinChannelWithRetry $peer $org
		    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME' ===================== "
		    sleep 2
		    echo
        done
	done
}

installChaincode () {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG
	peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/test/chaincode/go/vote >&log.txt
	res=$?
	cat log.txt
	verifyResult $res "Chaincode installation on peer peer${PEER}.org${ORG} has Failed"
	echo "===================== Chaincode is installed on peer${PEER}.org${ORG} ===================== "
	echo
}

instantiateChaincode () {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":[]}' -P "OR ('Org1MSP.peer','Org2MSP.peer')" >log.txt
	else
		peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":[]}' -P "OR ('Org1MSP.peer','Org2MSP.peer')" >log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Chaincode instantiation on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' failed"
	echo "===================== Chaincode is instantiated on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
	echo
}

chaincodeQuery () {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG
	EXPECTED_RESULT=$3
	echo "===================== Querying on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME'... ===================== "
	local rc=1
	local starttime=$(date +%s)

	while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
	do
        	sleep 3
        	echo "Attempting to Query peer${PEER}.org${ORG} ...$(($(date +%s)-starttime)) secs"
        	peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}' >log.txt
        	test $? -eq 0 && VALUE=$(cat log.txt | egrep '^[0-9]+$')
        	test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
	done
	echo
	cat log.txt
	if test $rc -eq 0 ; then
		echo "===================== Query successful on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
    	else
		echo "!!!!!!!!!!!!!!! Query result on peer${PEER}.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
        	echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
		echo
		exit 1
    	fi
}


chaincodeInitInvoke () {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG
	
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME -n mycc -c '{"Args":["initLedger"]}' >log.txt
	else
        peer chaincode invoke -o orderer.example.com:7050  --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -c '{"Args":["initLedger"]}' >log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Invoke execution on PEER$PEER failed "
	echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
	echo
}

# Create channel
echo "Creating channel..."
createChannel
#peer channel create -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/mychannel.tx

# Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel

# Install chaincode on peer0.org1, peer0.org2, peer1.org1 and peer1.org2
echo "Installing chaincode on peer0.org1..."
#peer chaincode install -n mycc -p github.com/hyperledger/fabric/test/chaincode/go/vote -v 1.0
installChaincode 0 1
echo "Install chaincode on peer0.org2..."
installChaincode 0 2
#echo "Installing chaincode on peer1.org1..."
#installChaincode 1 1
#echo "Install chaincode on peer1.org2..."
#installChaincode 1 2

#echo "instantiate chaincode on peer0.org1..."
#peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n mycc -v 1.0 -c '{"Args":[]}' -P "OR ('Org1MSP.peer','Org2MSP.peer')"

#echo "invoke chaincode..."
#peer chaincode invoke -C mychannel -n mycc -c '{"Args":["initLedger"]}'

#peer chaincode query -C mychannel -n mycc -c '{"Args":["getUserVote"]}'
#instantiateChaincode 0 1

#echo "invoke chaincode on peer0.org1..."
#chaincodeInitInvoke 0 1


echo "All done."
exit 0
