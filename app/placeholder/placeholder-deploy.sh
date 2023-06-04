#!/bin/bash
# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Script to assist in Dockerfile-based deployments.
# any errors? exit immediately.
set -e

# if deploying with a suffix (from infra/jobs.tf), adjust the config to suit the custom site
# https://firebase.google.com/docs/hosting/multisites#set_up_deploy_targets
if [[ -n $SUFFIX ]]; then
    json -I -f firebase.json -e "this.hosting.target='$SUFFIX'"
    UPDATED=true

    # Use template file to generate configuration
    envsubst  < firebaserc.tmpl > .firebaserc
    echo "Customised .firebaserc created to support site."
    cat .firebaserc
fi

# If anything was updated, then export the output.
if [[ -n $UPDATED ]]; then
    echo "Deploying with the following updated config: "
    cat firebase.json
fi

echo "Deploying placeholder to Firebase..."

firebase deploy --project "$PROJECT_ID" --only hosting
