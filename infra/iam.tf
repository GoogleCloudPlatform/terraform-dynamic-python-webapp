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

locals {
  # Lists of required roles
  server_iam_members = [
    "roles/cloudsql.client",
    "roles/run.viewer",
    "roles/cloudtrace.agent"
  ]
  client_iam_members = [
    "roles/run.viewer",
    "roles/firebasehosting.admin",
  ]
  automation_iam_members = [
    "roles/cloudsql.client"
  ]
  init_iam_members = [
    "roles/logging.logWriter",
    "roles/iam.serviceAccountUser",
    "roles/run.admin",
  ]
}

# Accounts

resource "google_service_account" "server" {
  account_id   = var.random_suffix ? "api-backend-${random_id.suffix.hex}" : "api-backend"
  display_name = "API Backend service account"
  depends_on   = [module.project_services]
}

resource "google_service_account" "client" {
  account_id   = var.random_suffix ? "client-frontend-${random_id.suffix.hex}" : "client-frontend"
  display_name = "Client Frontend service account"
  depends_on   = [module.project_services]
}

resource "google_service_account" "automation" {
  account_id   = var.random_suffix ? "automation-${random_id.suffix.hex}" : "automation"
  display_name = "Automation service account"
  depends_on   = [module.project_services]
}


resource "google_service_account" "init" {
  account_id   = var.random_suffix ? "init-startup-${random_id.suffix.hex}" : "init-startup"
  display_name = "Jump Start App Init SA"
  depends_on   = [module.project_services]
  count        = var.init ? 1 : 0
}

# Permissions

resource "google_project_iam_member" "server_permissions" {
  count = length(local.server_iam_members)

  project = var.project_id
  role    = local.server_iam_members[count.index]
  member  = "serviceAccount:${google_service_account.server.email}"
}

resource "google_project_iam_member" "client_permissions" {
  count = length(local.client_iam_members)

  project = var.project_id
  role    = local.client_iam_members[count.index]
  member  = "serviceAccount:${google_service_account.client.email}"
}

resource "google_project_iam_member" "automation_permissions" {
  count = length(local.automation_iam_members)

  project = var.project_id
  role    = local.automation_iam_members[count.index]
  member  = "serviceAccount:${google_service_account.automation.email}"
}

resource "google_project_iam_member" "init_permissions" {
  count = length(local.init_iam_members)

  project = var.project_id
  role    = local.init_iam_members[count.index]
  member  = "serviceAccount:${google_service_account.init[0].email}"
}
