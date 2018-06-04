# Openshift Demo 

This demo deploys:
* Openshift 3.7
* Service Catalog
* Prometheus
* Grafana
* Elasticsearch
* Kibana
* Fluentd
* Jaeger

TODO:
* Service Broker

Known issues:
* Elasticsearch not working for Openshift v3.7. (Issue and work-around described here: https://github.com/kubernetes/kubernetes/issues/2707)


Prerequisite:
* Install Docker


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
