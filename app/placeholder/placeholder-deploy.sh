#!/bin/bash
# Script to assist in Dockerfile-based deployments. 
# any errors? exit immediately. 
set -e

echo "Deploying placeholder to Firebase..."

firebase deploy --project $PROJECT_ID --only hosting
