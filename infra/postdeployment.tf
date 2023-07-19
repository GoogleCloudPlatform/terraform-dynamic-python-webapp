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


# used to collect access token, for authenticated POST commands
data "google_client_config" "current" {
}

# Job that uses pre-built docker image to deploy a placeholder website.
resource "google_cloud_run_v2_job" "placeholder" {
  name     = var.random_suffix ? "placeholder-${random_id.suffix.hex}" : "placeholder"
  location = var.region

  labels = var.labels

  template {
    template {
      service_account = google_service_account.client.email
      max_retries     = 1
      containers {
        image = local.placeholder_image

        # Variables consumed by /app/placeholder/placeholder-deploy.sh
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "SUFFIX"
          value = var.random_suffix ? random_id.suffix.hex : ""
        }
        env {
          name  = "FIREBASE_URL"
          value = local.firebase_url
        }
      }
    }
  }

  depends_on = [
    module.project_services
  ]
}


# execute the job by calling the API directly. Intended side-effect
# tflint-ignore: terraform_unused_declarations
data "http" "execute_placeholder_job" {
  url    = "https://${var.region}-run.googleapis.com/v2/projects/${var.project_id}/locations/${var.region}/jobs/${google_cloud_run_v2_job.placeholder.name}:run"
  method = "POST"
  request_headers = {
    Accept = "application/json"
  Authorization = "Bearer ${data.google_client_config.current.access_token}" }

  depends_on = [
    module.project_services,
    google_cloud_run_v2_job.placeholder,
  ]
}


resource "google_cloud_run_v2_job" "init" {
  name     = var.random_suffix ? "init-${random_id.suffix.hex}" : "init"
  location = var.region

  labels = var.labels

  template {
    template {
      service_account = google_service_account.init[0].email
      max_retries     = 1
      containers {
        image = local.init_image

        # Variables consumed by /app/init/init-execute.sh
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "SUFFIX"
          value = var.random_suffix ? random_id.suffix.hex : ""
        }
        env {
          name  = "REGION"
          value = var.region
        }
        env {
          name  = "SETUP_JOB"
          value = google_cloud_run_v2_job.setup.name
        }
        env {
          name  = "CLIENT_JOB"
          value = google_cloud_run_v2_job.client.name
        }
        env {
          name  = "FIREBASE_URL"
          value = local.firebase_url
        }
        env {
          name  = "SERVER_URL"
          value = google_cloud_run_v2_service.server.uri
        }

      }
    }
  }

  depends_on = [
    module.project_services
  ]
}


# execute the job, once it and other dependencies exit. Intended side-effect.
# tflint-ignore: terraform_unused_declarations
data "http" "execute_init_job" {
  count = var.init ? 1 : 0

  url    = "https://${var.region}-run.googleapis.com/v2/projects/${var.project_id}/locations/${var.region}/jobs/${google_cloud_run_v2_job.init.name}:run"
  method = "POST"
  request_headers = {
    Accept = "application/json"
  Authorization = "Bearer ${data.google_client_config.current.access_token}" }
  depends_on = [
    google_cloud_run_v2_job.init,
    google_cloud_run_v2_job.setup,
    google_cloud_run_v2_job.client,
    module.project_services,
    google_sql_database_instance.postgres,
  ]
}
