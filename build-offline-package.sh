#!/bin/bash
cd $(dirname ${BASH_SOURCE})

# init
rm -Rf ./build
rm -Rf /tmp/k8s.build.*

# zip
TEMP_DIR=$(mktemp -d -t k8s.build.XXXXXX)
echo $TEMP_DIR
cp -R . $TEMP_DIR/openshift
rm -Rf $TEMP_DIR/openshift/.git
tar cfvz $TEMP_DIR/openshift.tar.gz --directory=$TEMP_DIR/ openshift/

# copy result
mkdir build
mv $TEMP_DIR/openshift.tar.gz ./build/
rm -Rf $TEMP_DIR
