#!/usr/bin/env bash

echo "Installing Mission Control"

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
helm upgrade --install mission-control jfrog/mission-control \
    --set missionControl.jfrogUrl=http://artifactory-ha-nginx \
    --set missionControl.masterKey=$MASTER_KEY \
    --set missionControl.joinKey=$JOIN_KEY
