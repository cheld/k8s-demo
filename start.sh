#!/bin/bash
cd $(dirname ${BASH_SOURCE})

# Configuration
CATALOG_PATH=https://raw.githubusercontent.com/cheld/k8s-demo/master/config/catalog-aws.json
VERSION_OPENSHIFT=openshift-origin-client-tools-v3.9.0-191fece-linux-64bit
VERSION_ISTIO=istio-1.0.0
HOST_IP=$(/sbin/ip route | awk '/default/ { print $3 }')

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
  curl -SL https://github.com/istio/istio/releases/download/1.0.0/istio-1.0.0-linux.tar.gz | tar -xvzC bin/
fi


# Deploy Openshift
$OC cluster up --skip-registry-check=true --public-hostname=$HOST_IP #--service-catalog
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
$OC adm policy add-scc-to-user anyuid -z istio-cleanup-old-ca-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-mixer-post-install-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-mixer-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-pilot-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-sidecar-injector-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-galley-service-account -n istio-system

#$OC adm policy add-scc-to-user privileged -z istio-ingressgateway-service-account -n istio-system
#$OC adm policy add-scc-to-user hostnetwork -z istio-ingressgateway-service-account -n istio-system

$OC apply -f $DIR_ISTIO/install/kubernetes/istio-demo.yaml
#wait_for_pod istio-pilot
#wait_for_pod istio-tracing
wait_for_pod prometheus
wait_for_pod grafana

# Deploy Logging
#$OC adm policy add-scc-to-user anyuid -z default -n logging
#$OC apply -f $DIR_CONFIG/logging-stack.yaml
#$OC create -f $DIR_CONFIG/fluentd-istio.yaml
#wait_for_pod elasticsearch
#wait_for_pod kibana


# Deploy sample application
#$OC adm policy add-scc-to-user anyuid -z default -n myproject
#$OC adm policy add-scc-to-user privileged -z default -n myproject
#$OC apply -f <($ISTIOCTL kube-inject -f $DIR_ISTIO/samples/bookinfo/platform/kube/bookinfo.yaml)                                           
#$OC create -f $DIR_ISTIO/samples/bookinfo/networking/bookinfo-gateway.yaml
#wait_for_pod productpage
#wait_for_pod ratings
#wait_for_pod reviews

# Set variables
INGRESS_HOST=$HOST_IP
INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')


# Output for easy usage
echo 
echo
echo "-------------------------Bin----------------------------"
echo "sudo ln -sfn `pwd`/$OC /usr/local/bin/oc"
echo "sudo ln -sfn `pwd`/$ISTIOCTL /usr/local/bin/istioctl"
echo
echo "-----------------------Tools----------------------------"
echo "Prometeus"
echo "oc -n istio-system port-forward $(oc -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 &"
echo "http://localhost:9090/graph#%5B%7B%22range_input%22%3A%221h%22%2C%22expr%22%3A%22istio_double_request_count%22%2C%22tab%22%3A1%7D%5D"
echo "Jaeger"
echo "oc port-forward -n istio-system $(oc get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686 &"
echo "http://localhost:16686"
echo "Grafana"
echo "oc -n istio-system port-forward $(oc -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 &"
echo "http://localhost:3000/dashboard/db/istio-mesh-dashboard"
echo "Kibana"
echo "oc -n logging port-forward \$(oc -n logging get pod -l app=kibana -o jsonpath='{.items[0].metadata.name}') 5601:5601 &"
echo "http://localhost:5601/"
echo
echo "----------------------Variables-------------------------"
echo "export INGRESS_HOST=$INGRESS_HOST"
echo "export INGRESS_PORT=$INGRESS_PORT"
echo "export SECURE_INGRESS_PORT=$SECURE_INGRESS_PORT"
echo
echo
echo "-----------------------Links----------------------------"
echo "Openshift at https://$HOST_IP:8443"
echo "Example at http://$HOST_IP:$INGRESS_PORT/productpage"
echo
echo
echo

# Free disk space
# du -s -m -x -h * | sort -n

