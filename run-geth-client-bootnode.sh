#!/bin/sh
if [ -z "$1" ]; then
    echo "Please call with bootnode as paramter"
    exit
fi

geth \
	--datadir spacedata \
	--networkid 1337 \
	--nodiscover \
	--bootnodes ${1} \
	console
