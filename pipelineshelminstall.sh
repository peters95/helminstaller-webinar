#!/usr/bin/env bash

echo "Installing Pipelines"

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
helm upgrade --install pipelines jfrog/pipelines \
     --set pipelines.jfrogUrl=http://artifactory-ha-nginx \
     --set pipelines.jfrogUrlUI=http://artifactory-ha-nginx \
     --set pipelines.masterKey=$MASTER_KEY \
     --set pipelines.joinKey=$JOIN_KEY \
     --set pipelines.accessControlAllowOrigins_0=http://artifactory-ha-nginx \
     --set pipelines.accessControlAllowOrigins_1=http://artifactory-ha-nginx \
     --set pipelines.msg.uiUser=monitor \
     --set pipelines.msg.uiUserPassword=monitor \
     --set postgresql.enabled=true \
     --set postgresql.postgresqlUsername=apiuser \
     --set postgresql.postgresqlPassword=password \
     --set rabbitmq.rabbitmq.username=user \
     --set rabbitmq.rabbitmq.password=bitnami \
     --set rabbitmq.externalUrl=amqps://pipelines-rabbit.jfrog.tech \
     --set pipelines.api.externalUrl=http://pipelines-api.jfrog.tech \
     --set pipelines.www.externalUrl=http://pipelines-www.jfrog.tech
