#!/bin/sh
geth \
	--datadir spacedata \
	--networkid 1337 \
	--genesis SpacenetGenesis.json \
	console
