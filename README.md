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

Prerequisite:
* Docker installed


Install Demo:
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

## Customize Service Catalog

The service catalog broker implementation is taken from [`demo-broker`](https://github.com/cheld/demo-broker)

The catalog content is retrieved from a URL. By default:

``
CATALOG_PATH=https://raw.githubusercontent.com/cheld/k8s-demo/master/config/catalog-legacy.json
``

Customize as needed. If you want to implement your own broker, than create a REST service that produces such a JSON as a first step.
