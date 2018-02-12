#!/bin/sh
geth \
	--datadir spacedata \
	--networkid 1337 \
	--nodiscover \
	--rpc --rpcaddr 127.0.0.1 --rpcport 8545
