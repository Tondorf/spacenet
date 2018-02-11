#!/bin/sh
if [ -z "$2" ]; then
    echo "Please call with address and bootnode as paramter"
    exit
fi

geth \
	--datadir spacedata \
	--networkid 1337 \
	--nodiscover \
	--mine --minerthreads=1 \
	--rpc --rpcaddr 127.0.0.1 --rpcport 8545 \
	--rpcapi "web3,eth" --rpccorsdomain "http://localhost:8000" \
	--etherbase=${1} \
	--bootnodes ${2}
