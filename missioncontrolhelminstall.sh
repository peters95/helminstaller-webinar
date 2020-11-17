#!/usr/bin/env bash

echo "Installing Mission Control"

# Get command line args if passed
while getopts n:m:j: flag
do
    case "${flag}" in
        n) JFROG_NAMESPACE=${OPTARG};;
        m) MASTER_KEY=${OPTARG};;
        j) JOIN_KEY=${OPTARG};;
    esac
done

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
helm upgrade --install mission-control jfrog/mission-control \
    --set missionControl.jfrogUrl=http://artifactory-ha-nginx \
    --set missionControl.masterKey=$MASTER_KEY \
    --set missionControl.joinKey=$JOIN_KEY $NAMESPACE_COMMAND
