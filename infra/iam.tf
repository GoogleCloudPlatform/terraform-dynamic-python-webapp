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

# Service Accounts

locals {
  # Helpers for the clunky formatting of these values
  automation_SA = "serviceAccount:${google_service_account.automation.email}"
  server_SA     = "serviceAccount:${google_service_account.server.email}"
  client_SA     = "serviceAccount:${google_service_account.client.email}"
}

resource "google_service_account" "server" {
  account_id   = var.random_suffix ? "api-backend-${random_id.suffix.hex}" : "api-backend"
  display_name = "API Backend service account"
  depends_on   = [google_project_service.enabled]
}

resource "google_service_account" "client" {
  account_id   = var.random_suffix ? "client-frontend-${random_id.suffix.hex}" : "client-frontend"
  display_name = "Client Frontend service account"
  depends_on   = [google_project_service.enabled]
}

resource "google_service_account" "automation" {
  account_id   = var.random_suffix ? "automation-${random_id.suffix.hex}" : "automation"
  display_name = "Automation service account"
  depends_on   = [google_project_service.enabled]
}

resource "google_service_account" "compute" {
  account_id   = var.random_suffix ? "compute-startup-${random_id.suffix.hex}" : "compute-startup"
  display_name = "Head Start App Compute Instance SA"
  depends_on   = [google_project_service.enabled]
  count        = var.init ? 1 : 0
}

# The Cloud Run server can access the database
resource "google_project_iam_member" "server_permissions" {
  project    = var.project_id
  role       = "roles/cloudsql.client"
  member     = local.server_SA
  depends_on = [google_service_account.server]
}

# Cloud Build can access the database
resource "google_project_iam_member" "build_permissions" {
  project    = var.project_id
  role       = "roles/cloudsql.client"
  member     = local.automation_SA
  depends_on = [google_service_account.automation]
}

# Server needs introspection permissions
resource "google_project_iam_member" "server_introspection" {
  project    = var.project_id
  role       = "roles/run.viewer"
  member     = local.server_SA
  depends_on = [google_service_account.server]
}

# Client needs introspection permissions
resource "google_project_iam_member" "client_introspection" {
  project    = var.project_id
  role       = "roles/run.viewer"
  member     = local.client_SA
  depends_on = [google_service_account.client]
}

# Client may need permission to deploy the front end
resource "google_project_iam_member" "client_permissions" {
  project    = var.project_id
  role       = "roles/firebasehosting.admin"
  member     = local.client_SA
  depends_on = [google_service_account.client]
}

# GCE instance needs access to start Jobs
resource "google_project_iam_member" "computestartup_permissions" {
  project    = var.project_id
  role       = "roles/run.developer"
  member     = "serviceAccount:${google_service_account.compute[0].email}"
  depends_on = [google_service_account.compute]
  count      = var.init ? 1 : 0
}

# Server needs to write to Cloud Trace
resource "google_project_iam_member" "server_traceagent" {
  project    = var.project_id
  role       = "roles/cloudtrace.agent"
  member     = local.server_SA
  depends_on = [google_service_account.server]
}
