#!/bin/bash
cd $(dirname ${BASH_SOURCE})

# Configuration
CATALOG_PATH=https://raw.githubusercontent.com/cheld/k8s-demo/master/config/catalog-aws.json
VERSION_OPENSHIFT=openshift-origin-client-tools-v3.9.0-191fece-linux-64bit
VERSION_ISTIO=istio-0.8.0

# Shortcuts
OC=bin/$VERSION_OPENSHIFT/oc
ISTIOCTL=bin/$VERSION_ISTIO/bin/istioctl
DIR_ISTIO=bin/$VERSION_ISTIO
DIR_CONFIG=config/

# init
mkdir -p bin

# wait util
wait_for_pod(){
  while [ $($OC get pods --all-namespaces | grep $1 | wc -l) = "0" ]; do
      sleep 1
      echo "Waiting for pod $1 to be scheduled"
  done
  while [ $($OC get pod --all-namespaces -l app=$1 -o jsonpath='{.items[0].status.phase}') != 'Running' ]; do
      sleep 1
      echo "Waiting for pod $1 to come alive"
  done
}


# Download Openshift - its too large for git
if [ ! -f $OC ]; then
  curl -SL https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz | tar -xvzC bin/
fi

# Download Istio
if [ ! -d $DIR_ISTIO ]; then
  curl -SL https://github.com/istio/istio/releases/download/0.8.0/istio-0.8.0-linux.tar.gz | tar -xvzC bin/
fi


# Deploy Openshift
$OC cluster up #--service-catalog
$OC login -u system:admin

# Deploy Broker Demo
#$OC project demo-broker || oc new-project demo-broker
#$OC process -f $DIR_CONFIG/demo-broker-insecure.yaml -p IMAGE=docker.io/cheld/demobroker:3 -p CATALOG_PATH=$CATALOG_PATH | oc apply -f -

# Deploy Istio
$OC adm policy add-scc-to-user anyuid -z istio-ingress-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z default -n istio-system
$OC adm policy add-scc-to-user anyuid -z prometheus -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-egressgateway-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-citadel-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-ingressgateway-service-account -n istio-system

$OC adm policy add-scc-to-user privileged -z istio-ingressgateway-service-account -n istio-system
$OC adm policy add-scc-to-user hostnetwork -z istio-ingressgateway-service-account -n istio-system

$OC adm policy add-scc-to-user anyuid -z istio-cleanup-old-ca-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-mixer-post-install-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-mixer-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-pilot-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-sidecar-injector-service-account -n istio-system

$OC apply -f $DIR_ISTIO/install/kubernetes/istio-demo.yaml

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
$OC adm policy add-scc-to-user anyuid -z default -n myproject
$OC adm policy add-scc-to-user privileged -z default -n myproject
#$OC apply -f <($ISTIOCTL kube-inject -f $DIR_ISTIO/samples/bookinfo/kube/bookinfo.yaml)
#$OC create -f $DIR_ISTIO/samples/bookinfo/routing/bookinfo-gateway.yaml
#wait_for_pod productpage
#wait_for_pod ratings
#wait_for_pod reviews

# Set variables
HOST_IP=$(kubectl get po -l istio=ingressgateway -n istio-system -o 'jsonpath={.items[0].status.hostIP}')
#GATEWAY_PORT=$($OC get svc istio-ingressgateway -n istio-system -o jsonpath='{.spec.ports[0].nodePort}')
INGRESS_HOST=$HOST_IP
INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')


# Links
echo
echo "-------------------------------------------------------"
echo "Openshift at https://$HOST_IP:8443"
echo "Prometheus at http://$HOST_IP:9090"
echo "Jaeger at http://$HOST_IP:16686"
echo "Grafana at http://$HOST_IP:3000/dashboard/db/istio-dashboard"
echo "Kiban at http://$HOST_IP:5601/"
echo "Example at http://$HOST_IP:$GATEWAY_PORT/productpage"
echo "--------------------------------------------------------"
echo "export INGRESS_HOST=$INGRESS_HOST"
echo "export INGRESS_PORT=$INGRESS_PORT"
echo "export SECURE_INGRESS_PORT=$SECURE_INGRESS_PORT"


