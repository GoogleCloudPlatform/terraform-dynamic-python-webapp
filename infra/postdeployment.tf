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

  setup_job_name       = "setup${local.random_suffix_append}"
  client_job_name      = "client${local.random_suffix_append}"
  placeholder_job_name = "placeholder${local.random_suffix_append}"
  init_job_name        = "init${local.random_suffix_append}"
}

# used to collect access token, for authenticated POST commands
data "google_client_config" "current" {
}

## Placeholder - deploys a placeholder website - uses prebuilt image in /app/placeholder
resource "google_workflows_workflow" "placeholder" {
  count = var.init ? 1 : 0

  name            = local.placeholder_job_name
  region          = var.region
  service_account = google_service_account.init[0].id

  description = "Deploy a placeholder Firebase website"

  source_contents = templatefile("${path.module}/workflows/placeholder.yaml", {
    project_id      = var.project_id
    job_location    = var.region
    job_name        = local.placeholder_job_name
    image_name      = local.placeholder_image
    service_account = google_service_account.init[0].email
    suffix          = local.random_suffix_value
    firebase_url    = local.firebase_url
  })
}

# execute the trigger, once it and other dependencies exist. Intended side-effect.
# tflint-ignore: terraform_unused_declarations
data "http" "run_placeholder_workflow" {
  count = var.init ? 1 : 0

  url    = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.placeholder[0].id}/executions"
  method = "POST"
  request_headers = {
    Authorization = "Bearer ${data.google_client_config.current.access_token}"
  }
  depends_on = [
    google_workflows_workflow.placeholder
  ]
}


## Init - sets up the api, deploys the application. 
resource "google_workflows_workflow" "init" {
  count = var.init ? 1 : 0

  name            = local.init_job_name
  region          = var.region
  service_account = google_service_account.init[0].id

  description = "Setup API and deploy client application"

  source_contents = templatefile("${path.module}/workflows/init.yaml", {
    project_id      = var.project_id
    region          = var.region
    service_account = google_service_account.init[0].email
    suffix          = local.random_suffix_value
    suffix_append   = local.random_suffix_append

    client_image           = local.client_image
    client_service_account = google_service_account.client.email
    client_job_name        = local.client_job_name

    setup_image           = local.server_image
    setup_service_account = google_service_account.automation.email
    setup_job_name        = local.setup_job_name

    django_env                = google_secret_manager_secret.django_settings.secret_id
    django_superuser_password = google_secret_manager_secret.django_admin_password.secret_id
    cloudsql_instance         = google_sql_database_instance.postgres.connection_name
    firebase_url              = local.firebase_url
    service_name              = google_cloud_run_v2_service.server.name
    service_url               = google_cloud_run_v2_service.server.uri
  })
}


# execute the trigger, once it and other dependencies exist. Intended side-effect.
# tflint-ignore: terraform_unused_declarations
data "http" "run_init_workflow" {
  count = var.init ? 1 : 0

  url    = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.init[0].id}/executions"
  method = "POST"
  request_headers = {
    Authorization = "Bearer ${data.google_client_config.current.access_token}"
  }
  depends_on = [
    google_workflows_workflow.init
  ]
}
