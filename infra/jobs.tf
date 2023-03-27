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

resource "google_cloud_run_v2_job" "setup" {
  name     = var.random_suffix ? "setup-${random_id.suffix.hex}" : "setup"
  location = var.region

  labels = var.labels

  template {
    template {
      service_account = google_service_account.automation.email
      containers {
        image   = local.server_image
        command = ["setup"]
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
          name = "ADMIN_PASSWORD"
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.django_admin_password.secret_id
              version = "latest"
            }
          }
        }
        volume_mounts {
          name       = "cloudsql"
          mount_path = "/cloudsql"
        }
      }
      volumes {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [google_sql_database_instance.postgres.connection_name]
        }
      }
    }
  }
  depends_on = [
    google_secret_manager_secret_version.django_settings
  ]
}

resource "google_cloud_run_v2_job" "migrate" {
  name         = var.random_suffix ? "migrate-${random_id.suffix.hex}" : "migrate"
  location     = var.region

  labels = var.labels

  template {
    template {
      service_account = google_service_account.automation.email
      containers {
        image   = local.server_image
        command = ["migrate"]
        env {
          name = "DJANGO_ENV"
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.django_settings.secret_id
              version = "latest"
            }
          }
        }
        volume_mounts {
          name       = "cloudsql"
          mount_path = "/cloudsql"
        }
      }
      volumes {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [google_sql_database_instance.postgres.connection_name]
        }
      }
    }
  }
  depends_on = [
    google_secret_manager_secret_version.django_settings
  ]
}



resource "google_cloud_run_v2_job" "client" {

  name         = var.random_suffix ? "client-${random_id.suffix.hex}" : "client"
  location     = var.region

  labels = var.labels

  template {
    template {
      service_account = google_service_account.client.email
      containers {
        image = local.client_image
        env {
          name  = "SERVICE_NAME"
          value = google_cloud_run_v2_service.server.name
        }
        env {
          name  = "REGION"
          value = var.region
        }
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }

      }
    }
  }

  depends_on = [
    google_project_service.enabled
  ]
}
