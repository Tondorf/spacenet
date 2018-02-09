#!/bin/sh
echo "Generate address with personal.newAccount()"
echo "accounts/adresses are stored in spacedata/keystore/"
echo "query balance with eth.getBalance("ADRESS")"
echo "=================================================="
geth attach spacedata/geth.ipc
