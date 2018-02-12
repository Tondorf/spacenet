#!/bin/sh
geth \
	--identity `whoami` \
	init SpacenetGenesis.json \
	--datadir spacedata
cp static-nodes.json spacedata/static-nodes.json
