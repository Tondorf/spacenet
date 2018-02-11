#!/bin/sh
if [ -z "$1" ]; then
    echo "Please call with bootnode as paramter"
    exit
fi

geth \
	--datadir spacedata \
	--networkid 1337 \
	--nodiscover \
	--rpc --rpcaddr 127.0.0.1 --rpcport 8545 \
	#--rpcapi "web3,eth" --rpccorsdomain="chrome-extension://nkbihfbeogaeaoehlefnkodbefgpgknn" --rpccorsdomain="http://localhost:8000" \
	--bootnodes ${1}
	#console
