#!/bin/sh
geth \
	--datadir spacedata \
	--networkid 1337 \
	--nodiscover \
	--rpc --rpcaddr 127.0.0.1 --rpcport 8545 \
	--bootnodes "enode://723128f962572909eb0f794580452249193ace7e2f56d48fb4b890a0b51f5a3d82e99f6f7e39a9c6bae4344de2bc56640d2669f284a86f391b46502d99605b34@192.168.200.144:30303"
