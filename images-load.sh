#!/bin/bash
cd $(dirname ${BASH_SOURCE})

docker load -i images/offline.tar
