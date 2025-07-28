function explorer_config() {
  local NETWORK_NAME=$1
  local CHANNEL_NAME=$2
  local IMAGE_VERSION=$3
  sed -e "s/\${NETWORK_NAME}/$NETWORK_NAME/" \
      -e "s/\${CHANNEL_NAME}/$CHANNEL_NAME/" \
      -e "s/\${IMAGE_VERSION}/$IMAGE_VERSION/" \
      config/explorer/blockchain-explorer-template-v2.yaml
}

function start_explorer_v2() {
  push_fn "Construct explorer config"
  local version=${1}

  echo "$(explorer_config $NS $CHANNEL_NAME $version)" > config/explorer/blockchain-explorer-v2.yaml
  pop_fn

  push_fn "Start explorer v2"
  kubectl -n $NS apply -f config/explorer/blockchain-explorer-v2.yaml
  pop_fn
}