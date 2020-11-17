#!/usr/bin/env bash

echo "Checking Artifactory installation parameters..."

# Get command line args if passed
while getopts n:l:c:k:m:j:s: flag
do
    case "${flag}" in
        n) JFROG_NAMESPACE=${OPTARG};;
        l) ARTIFACTORY_LICENSE_FILE=${OPTARG};;
        c) ARTIFACTORY_TLS_CERT=${OPTARG};;
        k) ARTIFACTORY_TLS_KEY=${OPTARG};;
        m) MASTER_KEY=${OPTARG};;
        j) JOIN_KEY=${OPTARG};;
        s) SSL_OFFLOAD=${OPTARG};;
    esac
done

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

if [ -z "$ARTIFACTORY_LICENSE_FILE" ]
then
  echo "No license was not supplied. Please specify a file with valid licenses."
  exit 1
else
  LICENSE_EXIST=$(kubectl get secrets $NAMESPACE_COMMAND | grep artifactory-license | wc -l)
  if [[ "$LICENSE_EXIST" =~ (0) ]]
  then
    kubectl create secret generic artifactory-license --from-file=$ARTIFACTORY_LICENSE_FILE $NAMESPACE_COMMAND
  fi
  ARTIFACTORY_DATA_KEY=$(echo $ARTIFACTORY_LICENSE_FILE | sed 's:.*/::')
fi

if [ -z "$ARTIFACTORY_TLS_CERT" ]
then
  echo "A tls-cert was not supplied. Skipping TLS creation."
elif [ -z "$ARTIFACTORY_TLS_KEY" ]
then
  echo "A tls-key was not supplied. Skipping TLS creation."
else
  TLS_EXIST=$(kubectl get secrets $NAMESPACE_COMMAND | grep tls-ingress | wc -l)
  if [[ "$TLS_EXIST" =~ (0) ]]
  then
    kubectl create secret tls tls-ingress --cert=$ARTIFACTORY_TLS_CERT --key=$ARTIFACTORY_TLS_KEY $NAMESPACE_COMMAND
  fi
fi

if [ -z "$MASTER_KEY" ]
then
  echo "No unique master key was supplied. Default master key will be supplied."
  echo "Default master key should not be used for production environments!"
  MASTER_KEY=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
fi

if [ -z "$JOIN_KEY" ]
then
  echo "No unique join key was supplied. Default join key will be supplied."
  echo "Default join key should not be used for production environments!"
  JOIN_KEY=EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
fi

if [ -z "$SSL_OFFLOAD" ]
then
  SSL_OFFLOAD=false
fi

echo "Installing Artifactory HA with the following options:"
echo "Namespace: $JFROG_NAMESPACE"
echo "License file: $ARTIFACTORY_LICENSE_FILE"
echo "TLS cert: $ARTIFACTORY_TLS_CERT"
echo "TLS key: $ARTIFACTORY_TLS_KEY"
echo "Master key: $MASTER_KEY"
echo "Join key: $JOIN_KEY"
echo "SSL offload: $SSL_OFFLOAD"

helm repo add jfrog https://charts.jfrog.io/ 2&>ADVANCE_SETUP.md >/dev/null
helm repo update 2&>ADVANCE_SETUP.md >/dev/null
helm upgrade --install artifactory-ha jfrog/artifactory-ha \
      --set nginx.service.ssloffload=$SSL_OFFLOAD \
      --set nginx.tlsSecretName=tls-ingress \
      --set artifactory.node.replicaCount=2 \
      --set artifactory.masterKey=$MASTER_KEY \
      --set artifactory.joinKey=$JOIN_KEY \
      --set artifactory.license.secret=artifactory-license \
      --set artifactory.license.dataKey=$ARTIFACTORY_DATA_KEY $NAMESPACE_COMMAND

kubectl rollout status deployment/artifactory-ha-nginx -n $JFROG_NAMESPACE
ARTIFACTORY_IP_ADDRESS=$(kubectl get svc -n $JFROG_NAMESPACE | grep LoadBalancer | awk '{print $4}')
echo ""
echo "****************************************************************************"
echo "Successfully deployed JFrog Artifactory at http://${ARTIFACTORY_IP_ADDRESS}"
echo "Default user: admin"
echo "Default pass: password"
echo "****************************************************************************"
echo ""