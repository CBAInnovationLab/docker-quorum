#!/bin/bash

set -veu

: ${BLOCKMAKER_ADDRESS?"BLOCKMAKER_ADDRESS must be set"}
: ${BLOCKMAKER_PASSWORD?"BLOCKMAKER_PASSWORD must be set"}
: ${VOTER_ADDRESS?"VOTER_ADDRESS must be set"}
: ${VOTER_PASSWORD?"VOTER_PASSWORD must be set"}

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Configuring node 1"
mkdir -p qdata/coinbase/keystore
cp config/keys/coinbase qdata/coinbase/keystore
geth --datadir qdata/coinbase init config/genesis.json

ls -la
ls -la config

NETID=87234
GLOBAL_ARGS="--networkid $NETID --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum"

echo "[*] Starting Constellation nodes"
nohup constellation-node config/tm1.conf 2>> qdata/logs/constellation1.log &
sleep 1

echo "[*] Starting single blockmaker and voter node"
echo "$BLOCKMAKER_ADDRESS"
echo "$BLOCKMAKER_PASSWORD"
PRIVATE_CONFIG=config/tm1.conf nohup geth \
	$GLOBAL_ARGS \
	--datadir qdata/coinbase \
	--blockmakeraccount "$BLOCKMAKER_ADDRESS" \
	--blockmakerpassword "$BLOCKMAKER_PASSWORD" \
	--voteaccount "$VOTER_ADDRESS" \
	--votepassword "$VOTER_PASSWORD" \
	--singleblockmaker \
	--minblocktime 0 \
	--maxblocktime 1
