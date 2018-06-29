cd $(dirname ${BASH_SOURCE})
OC=bin/openshift-origin-client-tools-v3.7.2-282e43f-linux-64bit/oc

$OC cluster down
