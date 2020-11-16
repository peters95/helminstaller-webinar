#!/usr/bin/env bash

echo "Installing Pipelines"

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

echo "Waiting 1 minute for external IP addresses to expose via Network Load Balancer..."
sleep 60
echo "Please map the following external IP address to DNS urls."
API_IP_ADDR=$(kubectl get svc $NAMESPACE_COMMAND | grep "pipelines-pipelines-api")
WWW_IP_ADDR=$(kubectl get svc $NAMESPACE_COMMAND | grep "pipelines-pipelines-www")
RABBIT_IP_ADDR=$(kubectl get svc $NAMESPACE_COMMAND | grep "pipelines-rabbitmq")
echo "******************************************"
echo "Map $PIPELINE_API_URL to $API_IP_ADDR"
echo "Map $PIPELINE_WWW_URL to $WWW_IP_ADDR"
echo "Map $PIPELINE_RABBITMQ_URL to $RABBIT_IP_ADDR"
echo "******************************************"
echo "If any IP address is missing above wait a few moments and run:"
echo "kubectl get svc $NAMESPACE_COMMAND"
echo ""
echo "SUCCESS!"