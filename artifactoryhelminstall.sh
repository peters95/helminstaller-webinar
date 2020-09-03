#!/usr/bin/env bash

echo "Installing Artifactory HA"

if [ -z "$ARTIFACTORY_LICENSE_FILE" ]
then
  echo "Environment variable 'ARTIFACTORY_LICENSE_FILE' not set. Please specify a file with valid licenses."
  exit 1
else
  kubectl create secret generic artifactory-license --from-file=$ARTIFACTORY_LICENSE_FILE
  ARTIFACTORY_DATA_KEY=$(echo $ARTIFACTORY_LICENSE_FILE | sed 's:.*/::')
fi

if [ -z "$ARTIFACTORY_TLS_CERT" ]
then
  echo "Environment variable 'ARTIFACTORY_TLS_CERT' not set. Skipping TLS creation."
elif [ -z "$ARTIFACTORY_TLS_KEY" ]
then
  echo "Environment variable 'ARTIFACTORY_TLS_KEY' not set. Skipping TLS creation."
else
  kubectl create secret tls tls-ingress --cert=$ARTIFACTORY_TLS_CERT --key=$ARTIFACTORY_TLS_KEY
fi

if [ -z "$MASTER_KEY" ]
then
  MASTER_KEY=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
fi

if [ -z "$JOIN_KEY" ]
then
  JOIN_KEY=EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
fi

if [ -z "$SSL_OFFLOAD" ]
then
  SSL_OFFLOAD=false
fi

helm repo add jfrog https://charts.jfrog.io/
helm repo update
helm upgrade --install artifactory-ha jfrog/artifactory-ha \
      --set nginx.service.ssloffload=$SSL_OFFLOAD \
      --set nginx.tlsSecretName=tls-ingress \
      --set artifactory.node.replicaCount=2 \
      --set artifactory.masterKey=$MASTER_KEY \
      --set artifactory.joinKey=$JOIN_KEY \
      --set artifactory.license.secret=artifactory-license \
      --set artifactory.license.dataKey=$ARTIFACTORY_DATA_KEY