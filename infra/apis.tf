/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# Google Cloud Services to enable.
# This is done for local development.
# Testing uses test/setup/main.tf.

# Google Cloud Services to enable
module "project_services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "15.0.1"
  disable_services_on_destroy = false
  project_id                  = var.project_id
  enable_apis                 = var.enable_apis

  activate_apis = [
    # Default new project services.
    "bigquery.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudtrace.googleapis.com",
    "datastore.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "sql-component.googleapis.com",
    "storage.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",

    # Solution-specific services.
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "firebase.googleapis.com",
    "firebasehosting.googleapis.com",
    "pubsub.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
  ]
}
