#!/bin/sh
geth \
	--identity `whoami` \
	init SpacenetGenesis.json \
	--datadir spacedata
