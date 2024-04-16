#!/bin/bash

source .env
set -e

if [[ "$ENVIRONMENT" == "" ]]
    then
        echo "No ENV specified."
        exit 1
fi
UPPER_ENVIRONMENT=$(echo "$ENVIRONMENT" | tr '[:lower:]' '[:upper:]')
RPC_URL_VAR="${UPPER_ENVIRONMENT}_RPC_URL"
RPC_URL=${!RPC_URL_VAR}

if [[ "$RPC_URL" == "" ]]
    then
        echo "${RPC_URL_VAR} in .env file is empty."
        exit 1
fi
echo "ENVIRONMENT: $ENVIRONMENT, RPC_URL: $RPC_URL"

forge build

npx hardhat fun-sig

forge script foundry-script/RouterProxyDeploy.s.sol  --broadcast  --rpc-url="$RPC_URL" --aws --sender="$AWS_SENDER"

forge script foundry-script/LogicDeploy.s.sol  --broadcast  --rpc-url="$RPC_URL" --aws --sender="$AWS_SENDER"

forge script foundry-script/NFTImplDeploy.s.sol  --broadcast  --rpc-url="$RPC_URL" --aws --sender="$AWS_SENDER"

forge script foundry-script/ReactionDeploy.s.sol  --broadcast  --rpc-url="$RPC_URL" --aws --sender="$AWS_SENDER"

forge script foundry-script/CondDeploy.s.sol  --broadcast  --rpc-url="$RPC_URL" --aws --sender="$AWS_SENDER"

forge script foundry-script/CommunityNFTDeploy.s.sol  --broadcast  --rpc-url="$RPC_URL" --aws --sender="$AWS_SENDER"

forge script foundry-script/RouterAdd.s.sol  --broadcast  --rpc-url="$RPC_URL" --aws --sender="$AWS_SENDER"

forge script foundry-script/Initialize.s.sol  --ffi --broadcast  --rpc-url="$RPC_URL" --aws --sender="$AWS_SENDER"

printf 'Deployment completed! \n %s'  "$(cat ./addresses-"${ENVIRONMENT}".json)"

