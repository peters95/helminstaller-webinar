#!/usr/bin/env bash

echo "Installing Xray"

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
helm upgrade --install xray jfrog/xray \
     --set xray.jfrogUrl=http://artifactory-ha-nginx \
     --set xray.masterKey=$MASTER_KEY \
     --set xray.joinKey=$JOIN_KEY
