# JFrog Helm Installer Quickstart

## What is this?

Installer scripts to deploy all the JFrog unified platform into k8s via official JFrog helm charts.

## Why do I care?

Installing all our products via helm can be time consuming and at times frustrating for new users.

These scripts will show you the bare min options you need to get a working JFrog unified platform up on k8s.

## License Requirements

These helm installer scripts support on BYOL (bring your own license) JFrog platform installations.

If you don't have a license and want to evaluate our products, sign up for JFrog trial licenses [here.](https://jfrog.com/platform/free-trial/)

One Enterprise + license is required per node in our Artifactory HA cluster.

Once you receive your license keys via email save the base64 encoded strings into a text file `$HOME/artifactory.cluster.license` delimited by double new lines as shown below:

````bash
ABCDEF23905jidjfda907589h34n5ljndljf8495u
djfoijfd89u3458923jdlsjfidsuy85u8j34jkdjf
jodju89jdfj

DIOJidfjle490uj0dfojldjllj50290jojfldjflj
J)(DJV)DJlj3l4j9jsm0fj90d8su045ju3p4jldjf
oopdkfokdkf

FAKEDONOTTRYTOUSETHESEASREALLICENSEUSETHE
TRIALLINKABOVEIFYOUNEEDLICENSEKEYSFROMJFR
OGTOEVALUATE
````

## How to use?

### Installation Flags

````text
  n : Kubernetes namespace to use
  l : Local file with licenses to apply as kubernetes secret
````

### Install Artifactory

````bash
./artifactoryhelminstall.sh -n artifactory -l $HOME/artifactory.cluster.license 
````

### Install Xray
````bash
./xrayhelminstall.sh -n artifactory
````

### Install Distribution
````bash
./distributionhelminstall.sh -n artifactory
````

### Mission Control
````bash
./missioncontrolhelminstall.sh -n artifactory
````


## What does it do?

It will deploy Artifactory, Xray, Distribution, and Mission Control into your k8s cluster.

## Advance Setup

The advance setup guide to secure Artifactory with TLS or deploy to JFrog Pipelines can be found [here.](ADVANCE_SETUP.md)