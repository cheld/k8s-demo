# Openshift Demo

This demo deploys:
* Openshift 3.7
* Service Catalog
* Service Broker
* Istio
* Prometheus
* Grafana
* Elasticsearch
* Kibana
* Fluentd
* Jaeger
* Sample Application

All infrastructure is configured to work out-of-the-box.

TODO:
* Check if port binding allows outside connections
* Print URLs inluding IP instead of localhost

## Host Preparation
* Install Docker
* Add user to [docker group](https://docs.docker.com/install/linux/linux-postinstall/) 
* Update docker configuration for [insecure registry](https://about.gitlab.com/handbook/sales/idea-to-production-demo/setup/#insecure-local-registry-on-linux)

## Run Demo
The demo is dockerized and does not modify the host. 

Copy the sources:
``
$ git clone https://github.com/cheld/k8s-demo
``


Start Demo:
``
$ ./start-demo.sh
``

Clean up:
``
$ ./stop-demo.sh
``


## Run Demo without Internet

To run the demo on a target machine without internet connectivity:
* open [releases](https://github.com/cheld/k8s-demo/releases) and manually transfer one package to the target machine
* Unzip the downloaded package
* Run the script `images-load.sh` to copy all Docker images from the downloaded package to the target machine.
* Run the script `start.sh` to start the demo.


## Customize Service Catalog

The service catalog broker implementation is taken from [`demo-broker`](https://github.com/cheld/demo-broker)

The catalog content is retrieved from a URL. By default:

``
CATALOG_PATH=https://raw.githubusercontent.com/cheld/k8s-demo/master/config/catalog-legacy.json
``

Customize as needed. If you want to implement your own broker, than create a REST service that produces such a JSON as a first step.
