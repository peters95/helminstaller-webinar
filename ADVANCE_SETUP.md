# JFrog Helm Installer Webinar

## Advance Setup

### Master / Join Key

Artifactory should be set with a unique master and join key. Users will need `openssl` to run the below command to create unique keys:

`openssl rand -hex 32`

### TLS

A valid domain will be required to setup TLS with Artifactory.

Ability to add one DNS A record is required.

A TLS cert and key in DER format specific to this domain is required.

The TLS cert and key will be applied as a Kubernetes secret.

More information on Kubernetes TLS secrets can be found [here.](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets)

### JFrog Pipelines

A valid domain will be required to setup JFrog Pipelines.

Ability to add multiple DNS A records is required.

## How to use?

### Flags

````text
  n -> namespace to use
  l -> license file to apply
  c -> TLS cert in DER format to apply, if supplied
  k -> TLS key associated to TLS cert supplied
  m -> Unique master key for Artifactory
  j -> Cluster join key for JFrog platform products
  s -> SSL offload termination, if desired (true/false)
````

### Install Artifactory

````bash
# Create a new master key
MASTER_KEY=$(openssl rand -hex 32)

# Create a new join key
JOIN_KEY=$(openssl rand -hex 32)

# Install Artifactory
./artifactoryhelminstall.sh -n artifactory -l $HOME/artifactory.cluster.license -c $HOME/tls.crt -k $HOME/tls.key -m $MASTER_KEY -j $JOIN_KEY -s false
````

### Install Xray
````bash
./xrayhelminstall.sh -n artifactory -m $MASTER_KEY -j $JOIN_KEY
````

### Install Distribution
````bash
./distributionhelminstall.sh -n artifactory -m $MASTER_KEY -j $JOIN_KEY
````

### Mission Control
````bash
./missioncontrolhelminstall.sh -n artifactory -m $MASTER_KEY -j $JOIN_KEY
````

### Pipelines
````bash
./pipelineshelminstall.sh -n artifactory -m $MASTER_KEY -j $JOIN_KEY -a https://artifactory.example.com -r amqp://pipelines-rabbitmq.example.com -p http://pipelines-api.example.com -w http://pipelines-www.example.com
````

## What does it do?

It will deploy Artifactory, Xray, Distribution, Mission Control, and Pipelines into your k8s cluster.

## Master and Join Key

By default the helm installer scripts will use a basic masterKey and joinKey if none are supplied.

It is HIGHLY recommended you change these values. You can update these to a new value using openssl.

`openssl rand -hex 32`

## TLS

By default the helm chart will not enabled TLS.

To enable TLS you will need your TLS crt and key file.

Optionally, if you want to offload SSL to a third party provider or cluster edge.

## Pipelines DNS Requirement

Pipelines requires that the API, WWW, and Rabbitmq be exposed externally via DNS to be available to the build plane as this may run remotely in another cloud provider.

The installation script will display a mapping of DNS to IP address that must be saved to your DNS provider for pipelines to work as expected.

Add an A record in DNS for each exposed external IP address that you provided the URL as a flag to the pipeline installer.