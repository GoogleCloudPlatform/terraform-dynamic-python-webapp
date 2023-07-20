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

# topic that is never used in practice, except as a configuration type for Cloud Build Triggers
resource "google_pubsub_topic" "faux" {
  name = "faux-topic"
}

## Placeholder - deploys a placeholder website - uses prebuilt image in /app/placeholder
locals {
  random_suffix_value = var.random_suffix ? random_id.suffix.hex : ""
}

resource "google_cloudbuild_trigger" "placeholder" {
  name     = "placeholder"
  location = "us-central1"

  description = "Deploy a placeholder Firebase website"

  service_account = google_service_account.client.id

  pubsub_config {
    topic = google_pubsub_topic.faux.id
  }

  build {
    step {
      name = "gcr.io/${var.project_id}/placeholder" # TODO(glasnt) revert when fixed local.placeholder_image
      env = [
        "PROJECT_ID=${var.project_id}",
        "SUFFIX=${local.random_suffix_value}",
        "FIREBASE_URL=${local.firebase_url}",
      ]
    }

    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
  }
}


# execute the trigger, once it and other dependencies exist. Intended side-effect.
# tflint-ignore: terraform_unused_declarations
data "http" "execute_placeholder_trigger" {
  count = var.init ? 1 : 0

  url    = "https://cloudbuild.googleapis.com/v1/${google_cloudbuild_trigger.placeholder.id}:run"
  method = "POST"
  request_headers = {
    Authorization = "Bearer ${data.google_client_config.current.access_token}"
  }
  depends_on = [
    module.project_services,
    google_cloudbuild_trigger.placeholder
  ]
}


## Initalization trigger
resource "google_cloudbuild_trigger" "init" {
  name     = "init-application"
  location = "us-central1"

  description = "Perform initialization setup for server and client"

  pubsub_config {
    topic = google_pubsub_topic.faux.id
  }

  service_account = google_service_account.init[0].id

  build {
    #step {
    #  id      = "server-setup"
    #  name    = local.server_image
    #  entrypoint = "setup"
    #}
    step {
      id   = "client-setup"
      name = local.client_image
      env = [
        "PROJECT_ID=${var.project_id}",
        "SUFFIX=${var.random_suffix ? random_id.suffix.hex : ""}",
        "REGION=${var.region}",
        "FIREBASE_URL=${local.firebase_url}",
      ]
    }
    step {
      id     = "purge-firebase"
      name   = "gcr.io/distroless/static-debian11"
      script = "curl -X PURGE \"${local.firebase_url}/\""
    }
    step {
      id     = "warmup-api"
      name   = "gcr.io/distroless/static-debian11"
      script = "curl \"${google_cloud_run_v2_service.server.uri}/api/products/?warmup\""
    }

  }
}

# execute the trigger, once it and other dependencies exist. Intended side-effect.
# tflint-ignore: terraform_unused_declarations
data "http" "execute_init_trigger" {
  count = var.init ? 1 : 0

  url    = "https://cloudbuild.googleapis.com/v1/${google_cloudbuild_trigger.init.id}:run"
  method = "POST"
  request_headers = {
    Authorization = "Bearer ${data.google_client_config.current.access_token}"
  }
  depends_on = [
    module.project_services,
    google_sql_database_instance.postgres,
    google_cloudbuild_trigger.init,
  ]
}
