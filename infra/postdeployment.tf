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

## Post deployment steps
# Run the jobs created to populate database and client front-end. 


# https://github.com/terraform-google-modules/terraform-google-gcloud/issues/82#issuecomment-726501671 
module "execute-setup-job" {
  source        = "terraform-google-modules/gcloud/google"
  skip_download = true

  additional_components = ["beta"]
  create_cmd_body       = "beta run jobs execute ${google_cloud_run_v2_job.setup.name} --wait --project ${var.project_id} --region ${var.region}"

  module_depends_on = [
    google_cloud_run_v2_job.setup
  ]

  depends_on = [
    google_cloud_run_v2_job.setup
  ]
}

module "execute-client-job" {
  source        = "terraform-google-modules/gcloud/google"
  skip_download = true

  additional_components = ["beta"]
  create_cmd_body       = "beta run jobs execute ${google_cloud_run_v2_job.client.name} --wait --project ${var.project_id} --region ${var.region}"

  module_depends_on = [
    google_cloud_run_v2_job.client
  ]

  depends_on = [
    google_cloud_run_v2_job.setup
  ]
}
