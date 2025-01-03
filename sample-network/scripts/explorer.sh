function explorer_config() {
  local NETWORK_NAME=$1
  local CHANNEL_NAME=$2
  local IMAGE_VERSION=$3
  sed -e "s/\${NETWORK_NAME}/$NETWORK_NAME/" \
      -e "s/\${CHANNEL_NAME}/$CHANNEL_NAME/" \
      -e "s/\${IMAGE_VERSION}/$IMAGE_VERSION/" \
      config/explorer/blockchain-explorer-template.yaml
}

function start_explorer() {
  push_fn "Construct explorer config"
  ENROLLMENT_DIR=${TEMP_DIR}/enrollments
  CHANNEL_MSP_DIR=${TEMP_DIR}/channel-msp

  local cert=$ENROLLMENT_DIR/org1/users/org1admin/msp/signcerts/cert.pem
  local pk=$ENROLLMENT_DIR/org1/users/org1admin/msp/keystore/key.pem
  local tlsca=$CHANNEL_MSP_DIR/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem
  local version=${1}

  kubectl -n $NS delete configmap explorer-key-config || true
  kubectl -n $NS create configmap explorer-key-config --from-file=$ENROLLMENT_DIR/org1/users/org1admin/msp/keystore
  # kubectl -n fabric-network create configmap explorer-key-config --from-file=/data/source/fabric-samples/test-network-k8s/build/enrollments/org1/users/org1admin/msp/keystore

  kubectl -n $NS delete configmap explorer-cert-config || true
  kubectl -n $NS create configmap explorer-cert-config --from-file=$ENROLLMENT_DIR/org1/users/org1admin/msp/signcerts
  # kubectl -n fabric-network create configmap explorer-cert-config --from-file=/data/source/fabric-samples/test-network-k8s/build/enrollments/org1/users/org1admin/msp/signcerts

  kubectl -n $NS delete configmap explorer-tlsca-config || true
  kubectl -n $NS create configmap explorer-tlsca-config --from-file=$CHANNEL_MSP_DIR/peerOrganizations/org1/msp/tlscacerts
  # kubectl -n fabric-network create configmap explorer-tlsca-config --from-file=/data/source/fabric-samples/test-network-k8s/build/channel-msp/peerOrganizations/org1/msp/tlscacerts

  kubectl -n $NS delete configmap explorer-config || true
  echo "$(explorer_config $NS $CHANNEL_NAME $version)" > config/explorer/blockchain-explorer.yaml
  pop_fn

  push_fn "Start explorer pgsql"
  kubectl -n $NS apply -f config/explorer/blockchain-pgsql.yaml
  pop_fn

  push_fn "Start explorer"
  kubectl -n $NS apply -f config/explorer/blockchain-explorer.yaml
  pop_fn
}

function renew_explorer_cm() {
  push_fn "Construct explorer config"
  ENROLLMENT_DIR=${TEMP_DIR}/enrollments
  CHANNEL_MSP_DIR=${TEMP_DIR}/channel-msp

  local cert=$ENROLLMENT_DIR/org1/users/org1admin/msp/signcerts/cert.pem
  local pk=$ENROLLMENT_DIR/org1/users/org1admin/msp/keystore/key.pem
  local tlsca=$CHANNEL_MSP_DIR/peerOrganizations/org1/msp/tlscacerts/tlsca-signcert.pem

  kubectl -n $NS delete configmap explorer-key-config || true
  kubectl -n $NS create configmap explorer-key-config --from-file=$ENROLLMENT_DIR/org1/users/org1admin/msp/keystore
  # kubectl -n fabric-network create configmap explorer-key-config --from-file=/data/source/fabric-samples/test-network-k8s/build/enrollments/org1/users/org1admin/msp/keystore

  kubectl -n $NS delete configmap explorer-cert-config || true
  kubectl -n $NS create configmap explorer-cert-config --from-file=$ENROLLMENT_DIR/org1/users/org1admin/msp/signcerts
  # kubectl -n fabric-network create configmap explorer-cert-config --from-file=/data/source/fabric-samples/test-network-k8s/build/enrollments/org1/users/org1admin/msp/signcerts

  kubectl -n $NS delete configmap explorer-tlsca-config || true
  kubectl -n $NS create configmap explorer-tlsca-config --from-file=$CHANNEL_MSP_DIR/peerOrganizations/org1/msp/tlscacerts
  # kubectl -n fabric-network create configmap explorer-tlsca-config --from-file=/data/source/fabric-samples/test-network-k8s/build/channel-msp/peerOrganizations/org1/msp/tlscacerts

}
