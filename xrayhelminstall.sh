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

NAMESPACE_COMMAND=""
if [ -z "$JFROG_NAMESPACE" ]
then
  echo "No namespace specified. Installing into default namespace."
else
  NS_EXIST=$(kubectl get namespace | grep $JFROG_NAMESPACE | wc -l)
  if [[ "$NS_EXIST" =~ (0) ]]
  then
    kubectl create namespace $JFROG_NAMESPACE
  fi
  NAMESPACE_COMMAND="-n $JFROG_NAMESPACE"
fi

helm repo add jfrog https://charts.jfrog.io/
helm repo update
helm upgrade --install xray jfrog/xray \
     --set xray.jfrogUrl=http://artifactory-ha-nginx \
     --set xray.masterKey=$MASTER_KEY \
     --set xray.joinKey=$JOIN_KEY $NAMESPACE_COMMAND
