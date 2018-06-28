#!/bin/bash
cd $(dirname ${BASH_SOURCE})

# Clean
rm images/*
#docker rmi -f $(docker images -q)

# Start - stop to get all resources
#./start-demo.sh
#./stop-demo.sh

# Export all images
docker save $(docker images --format={{.Repository}}) -o images/offline.tar

echo "Done"
