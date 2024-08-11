#!/bin/bash

IROHA_SERVICE="http://172.16.101.17:3001"
JWT_TOKEN=$(cat .jwt-token)

GEN_KEY_PAIR_ENDPOINT="$IROHA_SERVICE"/api/v1/gen-key-pair
function prepareKeyPair() {
  NAME=$1
  if [ -f keypairs/"$NAME".json ]; then
    echo "keypairs/$NAME.json exists"
    return
  fi
  echo "prepare key pair for $NAME"
  curl -o keypairs/"$NAME".json $GEN_KEY_PAIR_ENDPOINT -H "Authorization: Bearer $JWT_TOKEN"
  jq -r '.public_key' keypairs/"$NAME".json > keypairs/"$NAME".pub
  jq -c '.private_key' keypairs/"$NAME".json > keypairs/"$NAME"-priv.json
}

# prepare key pairs for iroha node
prepareKeyPair "iroha"

# fetch genesis public key
GENESIS_ACCOUNT_PUBKEY_ENDPOINT="$IROHA_SERVICE"/api/v1/genesis-account-pubkey
curl -o keypairs/genesis.pub $GENESIS_ACCOUNT_PUBKEY_ENDPOINT -H "Authorization: Bearer $JWT_TOKEN"

# fetch trusted peers
TRUSTED_PEERS_ENDPOINT="$IROHA_SERVICE"/api/v1/trusted-peers
curl -o keypairs/trusted-peers.json $TRUSTED_PEERS_ENDPOINT -H "Authorization: Bearer $JWT_TOKEN"

MY_IP=$(hostname -I | awk '{print $1}')
function prepareEnv() {
  echo "preparing .env file"
  {
    echo "TORII_P2P_ADDR=$MY_IP:1337"
    echo "TORII_API_URL=$MY_IP:8080"
    echo "TORII_TELEMETRY_URL=$MY_IP:8180"
    echo "IROHA_PUBLIC_KEY=$(cat keypairs/iroha.pub)"
    echo "IROHA_PRIVATE_KEY=$(cat keypairs/iroha-priv.json)"
    echo "SUMERAGI_TRUSTED_PEERS=$(jq -c '.' keypairs/trusted-peers.json)"
    echo "IROHA_GENESIS_ACCOUNT_PUBLIC_KEY=$(cat keypairs/genesis.pub)"
    echo "IROHA_GENESIS_WAIT_FOR_PEERS_RETRY_COUNT_LIMIT=100"
    echo "IROHA_GENESIS_WAIT_FOR_PEERS_RETRY_PERIOD_MS=500"
    echo "IROHA_GENESIS_GENESIS_SUBMISSION_DELAY_MS=1000"
  } > .env
}

function prepareSubmission() {
  echo "preparing submission"
  {
    echo "TORII_P2P_ADDR=$MY_IP:1337"
    echo "IROHA_PUBLIC_KEY=$(cat keypairs/iroha.pub)"
  } > .submission
}

prepareEnv
prepareSubmission