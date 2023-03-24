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

resource "google_cloud_run_v2_service" "server" {
  name     = var.random_suffix ? "${var.service_name}-${random_id.suffix.hex}" : var.service_name
  location = var.region

  template {
    service_account = google_service_account.server.email
    containers {
      image = local.server_image
      env {
        name = "DJANGO_ENV"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.django_settings.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "PYTHONPATH"
        value = ""
      }
      env {
        name  = "DJANGO_SETTINGS_MODULE"
        value = "avocano_api.settings"
      }
      env {
        name  = "OTEL_METRICS_EXPORTER"
        value = "none"
      }
      env {
        name  = "OTEL_TRACES_EXPORTER"
        value = "gcp_trace"
      }
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
      startup_probe {
        http_get {
          path = "/ready"
        }
      }
      liveness_probe {
        http_get {
          path = "/healthy"
        }
      }
    }
    labels = var.labels
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.postgres.connection_name]
      }
    }
  }
  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
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
  location    = google_cloud_run_v2_service.server.location
  project     = google_cloud_run_v2_service.server.project
  service     = google_cloud_run_v2_service.server.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
