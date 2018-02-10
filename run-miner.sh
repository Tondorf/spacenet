#!/bin/sh
if [ -z "$2" ]; then
    echo "Please call with address and bootnode as paramter"
    exit
fi

geth \
	--datadir spacedata \
	--networkid 1337 \
	--genesis SpacenetGenesis.json \
	--mine --minerthreads=1 \
	--rpc --rpcaddr 127.0.0.1 --rpcport 8545 \
	--etherbase=${1} \
	--bootnodes ${2}