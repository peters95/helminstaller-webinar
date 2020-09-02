#!/usr/bin/env bash

echo "Installing Distribution"

if [ -z "$MASTER_KEY" ]
then
  MASTER_KEY=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
fi

if [ -z "$JOIN_KEY" ]
then
  JOIN_KEY=EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
fi

helm repo add jfrog https://charts.jfrog.io/
helm repo update
helm upgrade distribution jfrog/distribution \
     --set distribution.jfrogUrl=http://artifactory-ha-nginx \
     --set distribution.masterKey=$MASTER_KEY \
     --set distribution.joinKey=$JOIN_KEY
