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
  server_url = google_cloud_run_service.server.status[0].url
}

output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "firebase_url" {
  value = "https://${var.project_id}.web.app"
}

output "django_admin_url" {
  value = "${local.server_url}/admin"
}

output "django_admin_password" {
  sensitive = true
  value     = google_secret_manager_secret_version.django_admin_password.secret_data
}


output "usage" {
  sensitive = true
  value     = <<-EOF
    This deployment is now ready for use!
    https://${var.project_id}.web.app
    API Login:
    ${google_cloud_run_service.server.status[0].url}/admin
    Username: admin
    Password: ${google_secret_manager_secret_version.django_admin_password.secret_data}
    EOF
}
