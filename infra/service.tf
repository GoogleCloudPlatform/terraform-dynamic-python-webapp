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

resource "google_cloud_run_service" "server" {
  name                       = var.random_suffix ? "${var.service_name}-${random_id.suffix.hex}" : var.service_name
  location                   = var.region
  autogenerate_revision_name = true

  template {
    spec {
      service_account_name = google_service_account.server.email
      containers {
        image = local.server_image
        env {
          name = "DJANGO_ENV"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.django_settings.secret_id
              key  = "latest"
            }
          }
        }
      }
    }
    metadata {
      labels = var.labels
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "100"
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.postgres.connection_name
        "run.googleapis.com/client-name"        = "terraform"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_secret_manager_secret_version.django_settings
  ]
}


# Allow server to be public readable. 
data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "server_noauth" {
  location    = google_cloud_run_service.server.location
  project     = google_cloud_run_service.server.project
  service     = google_cloud_run_service.server.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
