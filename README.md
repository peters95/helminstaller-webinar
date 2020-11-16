# JFrog Helm Installer Webinar

## What is this?

Installer scripts to deploy all the JFrog unified platform into k8s via official JFrog helm charts.

## Why do I care?

Installing all our products via helm can be time consuming and at times frustrating for new users.

These scripts will show you the bare min options you need to get a working JFrog unified platform up on k8s.

## License Requirements

Ent/E+ licenses are required to use all of the JFrog Platform products.

3 or more Ent/E+ licenses are required to setup an Artifactory HA cluster.

Save your licenses into a new file 'artifactory.cluster.license'

````bash
vi $HOME/artifactory.cluster.license
````

Then export a new environment variable ARTIFACTORY_LICENSE_FILE that points to this file.

````bash
export ARTIFACTORY_LICENSE_FILE=$HOME/artifactory.cluster.license
````

## How to use?

### Install Artifactory

````bash
./artifactoryhelminstall.sh
````

### Install Xray
````bash
./xrayhelminstall.sh
````

### Install Distribution
````bash
./distributionhelminstall.sh
````

### Mission Control
````bash
./missioncontrolhelminstall.sh
````

### Pipelines
````bash
./pipelineshelminstall.sh
````

## What does it do?

It will deploy Artifactory, Xray, Distribution, Mission Control, and Pipelines into your k8s cluster.

You will need to add DNS to the external IP address exposed by the artifactory-ha-nginx service for SSL to be enabled.


## Master and Join Key

By default the helm installer scripts will use a basic masterKey and joinKey if none are supplied.

It is HIGHLY recommended you change these values. You can update these to a new value using openssl.

````bash
# Create a new master key
export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}
````

````bash
# Create a new join key
export JOIN_KEY=$(openssl rand -hex 32)
echo ${JOIN_KEY}
````

Once these are set you can then run the helm installer which will pick up on the new keys.

## TLS Setup

By default the helm chart will not enabled TLS.

To enable TLS you will need your TLS crt and key file.

Export two new environment variables as shown below for each file:

````bash
export ARTIFACTORY_TLS_CERT=/path/to/tls.crt
````

````bash
export ARTIFACTORY_TLS_KEY=/path/to/tls.key
````

Optionally if you want to offload SSL to a third party provider like Cloudflare use:

````bash
export SSL_OFFLOAD=true
````

## Namespace Usage

To use a different namespace for the installation export the environment variable below with the namespace you would like to deploy into.

````bash
export JFROG_NAMESPACE=artifactory
````

If this environment variable is set the namespace will be created and used for all deployments.

## Pipelines DNS Requirement

Pipelines requires that the API, WWW, and Rabbitmq be exposed externally via DNS to be available to the build plane as this may run remotely in another cloud provider.

The installation script will display a mapping of DNS to IP address that must be saved to your DNS provider for pipelines to work as expected.

Alternatively, you can enable ingress and provide the corresponding host and tls secret if your Kubernetes does not support NetworkLoadBalancers or you do not wish to use them.

