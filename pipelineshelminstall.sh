#!/usr/bin/env bash

echo "Checking Pipelines installation parameters..."

# Get command line args if passed
while getopts n:a:r:p:w:m:j: flag
do
    case "${flag}" in
        n) JFROG_NAMESPACE=${OPTARG};;
        a) ARTIFACTORY_URL=${OPTARG};;
        r) PIPELINE_RABBITMQ_URL=${OPTARG};;
        p) PIPELINE_API_URL=${OPTARG};;
        w) PIPELINE_WWW_URL=${OPTARG};;
        m) MASTER_KEY=${OPTARG};;
        j) JOIN_KEY=${OPTARG};;
    esac
done

if [ -z "$ARTIFACTORY_URL" ]
then
  echo "Please specify the DNS url used by Artifactory"
  echo "Ex: https://artifactory.example.com"
  exit 1
fi

if [ -z "$PIPELINE_RABBITMQ_URL" ]
then
  echo "Please specify the DNS url to be used by the Pipeline Rabbitmq"
  echo "Ex: amqp://rabbitmq.example.com"
  exit 1
fi

if [ -z "$PIPELINE_API_URL" ]
then
  echo "Please specify the DNS url to be used by the Pipeline API"
  echo "Ex: http://pipelines-api.example.com"
  exit 1
fi

if [ -z "$PIPELINE_WWW_URL" ]
then
  echo "Please specify the DNS url to be used by the Pipeline WWW"
  echo "Ex: http://pipelines-www.example.com"
  exit 1
fi

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

echo "Installing JFrog Pipelines with following options:"
echo "Namespace: $JFROG_NAMESPACE"
echo "Artifactory DNS Url: $ARTIFACTORY_URL"
echo "Rabbitmq DNS Url: $PIPELINE_RABBITMQ_URL"
echo "Pipeline API DNS Url: $PIPELINE_API_URL"
echo "Pipeline WWW DNS Url: $PIPELINE_WWW_URL"
echo "Master key: $MASTER_KEY"
echo "Join key: $JOIN_KEY"

helm repo add jfrog https://charts.jfrog.io/
helm repo update
helm upgrade --install pipelines jfrog/pipelines \
     --set pipelines.jfrogUrl=http://artifactory-ha-artifactory-ha-primary:8082 \
     --set pipelines.jfrogUrlUI=$ARTIFACTORY_URL \
     --set pipelines.masterKey=$MASTER_KEY \
     --set pipelines.joinKey=$JOIN_KEY \
     --set pipelines.accessControlAllowOrigins_0=$ARTIFACTORY_URL \
     --set pipelines.accessControlAllowOrigins_1=$ARTIFACTORY_URL \
     --set pipelines.msg.uiUser=monitor \
     --set pipelines.msg.uiUserPassword=monitor \
     --set postgresql.enabled=true \
     --set postgresql.postgresqlUsername=apiuser \
     --set postgresql.postgresqlPassword=password \
     --set rabbitmq.auth.password=bitnami \
     --set rabbitmq.externalUrl=$PIPELINE_RABBITMQ_URL \
     --set rabbitmq.service.type=LoadBalancer \
     --set pipelines.api.externalUrl=$PIPELINE_API_URL:30000 \
     --set pipelines.api.service.type=LoadBalancer \
     --set pipelines.www.externalUrl=$PIPELINE_WWW_URL::30001 \
     --set pipelines.www.service.type=LoadBalancer $NAMESPACE_COMMAND

kubectl rollout status statefulset/pipelines-pipelines-services $NAMESPACE_COMMAND

API_IP_ADDR=$(kubectl get svc pipelines-pipelines-api $NAMESPACE_COMMAND -o jsonpath="{.status.loadBalancer.ingress[*]['ip', 'hostname']}")
WWW_IP_ADDR=$(kubectl get svc pipelines-pipelines-www $NAMESPACE_COMMAND -o jsonpath="{.status.loadBalancer.ingress[*]['ip', 'hostname']}")
RABBIT_IP_ADDR=$(kubectl get svc pipelines-rabbitmq $NAMESPACE_COMMAND -o jsonpath="{.status.loadBalancer.ingress[*]['ip', 'hostname']}")
echo "Please map the following external IP address to DNS urls."
echo "******************************************"
echo "Map $PIPELINE_API_URL to $API_IP_ADDR"
echo "Map $PIPELINE_WWW_URL to $WWW_IP_ADDR"
echo "Map $PIPELINE_RABBITMQ_URL to $RABBIT_IP_ADDR"
echo "******************************************"
echo "Successfully installed JFrog Pipelines!"
