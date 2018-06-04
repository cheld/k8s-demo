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

Known issues:
* Elasticsearch not working for Openshift v3.7. (Issue and work-around described here: https://github.com/kubernetes/kubernetes/issues/2707) Disable logging part before running the script (or use Openshift3.9)


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
