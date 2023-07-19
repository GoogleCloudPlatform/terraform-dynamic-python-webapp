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

# escape if project_id not defined (mandatory, required later)
if [[ -z $PROJECT_ID ]]; then
   echo "PROJECT_ID not defined. Cannot deploy. Exiting."
   exit 1
fi

# escape if firebase_url not defined (mandatory, required later)
if [[ -z $FIREBASE_URL ]]; then
   echo "FIREBASE_URL not defined. Cannot deploy. Exiting."
   exit 1
fi

# Define common defaults, all overrideable.
REGION="${REGION:-us-central1}"
SETUP_JOB="${SETUP_JOB:-setup}"
CLIENT_JOB="${CLIENT_JOB:-client}"

echo "*** Executing initization job ***"
echo "PROJECT_ID:   $PROJECT_ID"
echo "REGION:       $REGION"
echo "SETUP JOB:    $SETUP_JOB"
echo "CLIENT JOB:   $CLIENT_JOB"
echo "FIREBASE URL: $FIREBASE_URL"
echo "SERVER URL:   $SERVER_URL"
echo ""

echo "Running init database migration..."
gcloud run jobs execute "$SETUP_JOB" --wait --project "$PROJECT_ID" --region "$REGION"

echo "Running client deploy..."
gcloud run jobs execute "$CLIENT_JOB" --wait --project "$PROJECT_ID" --region "$REGION"

echo "Purge Firebase cache"
echo curl -X PURGE "${FIREBASE_URL}/"

echo "Warm up API"
curl "${SERVER_URL}/api/products/?warmup"
