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
  random_suffix_value  = var.random_suffix ? random_id.suffix.hex : ""       # literal value  (NNNN)
  random_suffix_append = var.random_suffix ? "-${random_id.suffix.hex}" : "" # appended value (-NNNN)

  setup_job_name  = "setup${local.random_suffix_append}"
  client_job_name = "client${local.random_suffix_append}"

  gcloud_step_container = "gcr.io/google.com/cloudsdktool/cloud-sdk:slim"
}

# used to collect access token, for authenticated POST commands
data "google_client_config" "current" {
}

# topic that is never used, except as a configuration type for Cloud Build Triggers
resource "google_pubsub_topic" "faux" {
  name = "faux-topic${local.random_suffix_append}"
}

## Placeholder - deploys a placeholder website - uses prebuilt image in /app/placeholder
resource "google_cloudbuild_trigger" "placeholder" {
  count = var.init ? 1 : 0

  name     = "placeholder${local.random_suffix_append}"
  location = var.region

  description = "Deploy a placeholder Firebase website"

  pubsub_config {
    topic = google_pubsub_topic.faux.id
  }

  service_account = google_service_account.init[0].id

  build {
    step {
      id   = "deploy-placeholder"
      name = local.placeholder_image
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

  depends_on = [
    # Depends on permission assignment to the init service account.
    # If there are IAM propagation delays, define an intermediary time_sleep resource.
    google_project_iam_member.init_permissions
  ]
}


# execute the trigger, once it and other dependencies exist. Intended side-effect.
# tflint-ignore: terraform_unused_declarations
data "http" "execute_placeholder_trigger" {
  count = var.init ? 1 : 0

  url    = "https://cloudbuild.googleapis.com/v1/${google_cloudbuild_trigger.placeholder[0].id}:run"
  method = "POST"
  request_headers = {
    Authorization = "Bearer ${data.google_client_config.current.access_token}"
  }
  depends_on = [
    google_cloudbuild_trigger.placeholder[0]
  ]
}


## Initalization trigger
resource "google_cloudbuild_trigger" "init" {
  count = var.init ? 1 : 0

  name     = "init-application${local.random_suffix_append}"
  location = var.region

  description = "Perform initialization setup for server and client"

  pubsub_config {
    topic = google_pubsub_topic.faux.id
  }

  service_account = google_service_account.init[0].id

  build {
    ## Client/frontend processing
    step {
      # Check if a job already exists under the exact name. If it doesn't, create it.
      # Environment variables used to customise Firebase configuration on deployment
      # https://github.com/GoogleCloudPlatform/avocano/blob/main/client/docker-deploy.sh
      id     = "create-client-job"
      name   = local.gcloud_step_container
      script = <<EOT
#!/bin/bash
SETUP_JOB=$(gcloud run jobs list --filter "metadata.name~${local.client_job_name}$" --format "value(metadata.name)" --region ${var.region})

if [[ -z $SETUP_JOB ]]; then
  echo "Creating ${local.client_job_name} Cloud Run Job"
  gcloud run jobs create ${local.client_job_name} --region ${var.region} \
    --image ${local.client_image} \
    --service-account ${google_service_account.client.email} \
    --set-env-vars PROJECT_ID=${var.project_id} \
    --set-env-vars SUFFIX=${local.random_suffix_value} \
    --set-env-vars REGION=${var.region} \
    --set-env-vars SERVICE_NAME=${google_cloud_run_v2_service.server.name}
else
  echo "Cloud Run Job ${local.client_job_name} already exists."
fi
EOT
    }

    ## Server/API processing
    step {
      # Check if a job already exists under the exact name. If it doesn't, create it.
      id     = "create-setup-job"
      name   = local.gcloud_step_container
      script = <<EOT
#!/bin/bash
SETUP_JOB=$(gcloud run jobs list --filter "metadata.name~${local.setup_job_name}$" --format "value(metadata.name)" --region ${var.region})

if [[ -z $SETUP_JOB ]]; then
  echo "Creating ${local.setup_job_name} Cloud Run Job"
  gcloud run jobs create ${local.setup_job_name} --region ${var.region} \
    --command setup \
    --image ${local.server_image} \
    --service-account ${google_service_account.automation.email} \
    --set-secrets DJANGO_ENV=${google_secret_manager_secret.django_settings.secret_id}:latest \
    --set-secrets DJANGO_SUPERUSER_PASSWORD=${google_secret_manager_secret.django_admin_password.secret_id}:latest \
    --set-cloudsql-instances ${google_sql_database_instance.postgres.connection_name}
else
  echo "Cloud Run Job ${local.setup_job_name} already exists."
fi
EOT
    }

    # Now that the jobs definitely exist, execute them.
    step {
      id     = "execute-setup-job"
      name   = local.gcloud_step_container
      script = "gcloud run jobs execute ${local.setup_job_name} --wait --region ${var.region} --project ${var.project_id}"
    }

    step {
      id     = "execute-client-job"
      name   = local.gcloud_step_container
      script = "gcloud run jobs execute ${local.client_job_name} --wait --region ${var.region} --project ${var.project_id}"
    }

    # Ensure any cached versions of the application are purged
    # Preemptively warm up the server API
    step {
      id     = "purge-and-warmfirebase"
      name   = "ubuntu"
      script = <<EOT
#!/bin/bash
apt-get update && apt-get install curl -y
curl -X PURGE "${local.firebase_url}/"
curl "${google_cloud_run_v2_service.server.uri}/api/products/?warmup"
EOT
    }

    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
  }

  depends_on = [
    google_sql_database_instance.postgres,
    google_cloud_run_v2_job.migrate
  ]
}

# execute the trigger, once it and other dependencies exist. Intended side-effect.
# tflint-ignore: terraform_unused_declarations
data "http" "execute_init_trigger" {
  count = var.init ? 1 : 0

  url    = "https://cloudbuild.googleapis.com/v1/${google_cloudbuild_trigger.init[0].id}:run"
  method = "POST"
  request_headers = {
    Authorization = "Bearer ${data.google_client_config.current.access_token}"
  }
  depends_on = [
    google_cloudbuild_trigger.init[0],
  ]
}
