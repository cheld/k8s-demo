#!/bin/bash
cd $(dirname ${BASH_SOURCE})

# Configuration
CATALOG_PATH=https://raw.githubusercontent.com/cheld/k8s-demo/master/config/catalog.json
VERSION_OPENSHIFT=openshift-origin-client-tools-v3.7.2-282e43f-linux-64bit
VERSION_ISTIO=istio-0.7.1

# Shortcuts
OC=bin/$VERSION_OPENSHIFT/oc
ISTIOCTL=bin/$VERSION_ISTIO/bin/istioctl
DIR_ISTIO=bin/$VERSION_ISTIO
DIR_CONFIG=config/

# wait util
wait_for_pod(){
  while [ $(oc get pods --all-namespaces | grep $1 | wc -l) = "0" ]; do
      sleep 1
      echo "Waiting for pod $1 to be scheduled"
  done
  while [ $(oc get pod --all-namespaces -l app=$1 -o jsonpath='{.items[0].status.phase}') != 'Running' ]; do
      sleep 1
      echo "Waiting for pod $1 to come alive"
  done
}


# Download Openshift - its too large for git
if [ ! -f $OC ]; then
  curl -SL https://github.com/openshift/origin/releases/download/v3.7.2/openshift-origin-client-tools-v3.7.2-282e43f-linux-64bit.tar.gz | tar -xvzC bin/
fi
# Download Istio
if [ ! -d $DIR_ISTIO ]; then
  curl -SL https://github.com/istio/istio/releases/download/0.7.1/istio-0.7.1-linux.tar.gz | tar -xvzC bin/
fi


# Deploy Openshift
$OC cluster up --service-catalog
$OC login -u system:admin

# Deploy Demo
oc project demo-broker || oc new-project demo-broker
oc process -f openshift/demo-broker-insecure.yaml -p IMAGE=docker.io/cheld/demobroker:3 -p CATALOG_PATH=$CATALOG_PATH | oc apply -f -

# Deploy Istio
#$OC adm policy add-scc-to-user anyuid -z istio-ingress-service-account -n istio-system
#$OC adm policy add-scc-to-user anyuid -z default -n istio-system
#$OC adm policy add-scc-to-user privileged -z default -n myproject
#$OC apply -f $DIR_ISTIO/install/kubernetes/istio.yaml

# Deploy prometheus
#$OC adm policy add-scc-to-user anyuid -z prometheus -n istio-system
#$OC apply -f $DIR_ISTIO/install/kubernetes/addons/prometheus.yaml
#wait_for_pod prometheus
#$OC -n istio-system port-forward $($OC -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 &

# Install grafana
#$OC adm policy add-scc-to-user anyuid -z grafana -n istio-system
#$OC apply -f $DIR_ISTIO/install/kubernetes/addons/grafana.yaml
#wait_for_pod grafana
#$OC -n istio-system port-forward $($OC -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 &

# Deploy Logging
#$OC adm policy add-scc-to-user anyuid -z default -n logging
#$OC apply -f $DIR_CONFIG/logging-stack-openshiftv3.7.yaml
#wait_for_pod elasticsearch
#wait_for_pod kibana
#$OC -n logging port-forward $($OC -n logging get pod -l app=kibana -o jsonpath='{.items[0].metadata.name}') 5601:5601 &
#$ISTIOCTL create -f $DIR_CONFIG/fluentd-istio.yaml

# Deploy Jeager
#$OC apply -n istio-system -f https://raw.githubusercontent.com/jaegertracing/jaeger-kubernetes/master/all-in-one/jaeger-all-in-one-template.yml
#wait_for_pod jaeger
#$OC port-forward -n istio-system $($OC get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686 &

# Deploy sample application
#$OC apply -f <($ISTIOCTL kube-inject --debug -f $DIR_ISTIO/samples/bookinfo/kube/bookinfo.yaml)
#wait_for_pod ratings
#wait_for_pod reviews
#wait_for_pod productpage
#GATEWAY_PORT=$($OC get svc istio-ingress -n istio-system -o jsonpath='{.spec.ports[0].nodePort}')


# Links
echo
echo "-------------------------------------------------------"
echo "Openshift at https://127.0.0.1:8443"
echo "Prometheus at http://localhost:9090"
echo "Jaeger at http://localhost:16686"
echo "Grafana at http://localhost:3000/dashboard/db/istio-dashboard"
echo "Kiban at http://localhost:5601/"
echo "Example at http://localhost:$GATEWAY_PORT/productpage"
echo "--------------------------------------------------------"
