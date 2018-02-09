#!/bin/sh
if [ -z "$2" ]; then
    echo "Please call with address and bootnode as paramter"
    exit
fi

geth \
	--datadir spacedata \
	--networkid 1337 \
	--mine --minerthreads=1 \
	--etherbase=${1} \\
	--bootnodes ${2}
