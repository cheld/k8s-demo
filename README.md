# Openshift Demo

This demo deploys:
* Openshift 3.7
* Service Catalog
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
* Add service broker instance
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
