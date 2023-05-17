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
  server_url   = google_cloud_run_v2_service.server.uri
  firebase_url = var.random_suffix ? google_firebase_hosting_site.client.default_url : "https://${var.project_id}.web.app"
}

output "firebase_url" {
  description = "Firebase URL"
  value       = local.firebase_url
}

locals {
  toggleCommerceActive = length(split("serverless-ecommerce", var.client_image_host)) > 1
  neosUrlTemplate      = "https://console.cloud.google.com/products/solutions/deployments?walkthrough_id=panels--sic--%s_toc"
  jssDynamicWebApp     = "dynamic-python-web-app"
  jssCommerceApp       = "ecommerce-serverless"
}

output "neos_toc_url" {
  description = "Neos Tutorial URL"
  value = (
    local.toggleCommerceActive ?
    format(local.neosUrlTemplate, local.jssCommerceApp) :
    format(local.neosUrlTemplate, local.jssDynamicWebApp)
  )
}

output "django_admin_url" {
  description = "Djando Admin URL"
  value       = "${local.server_url}/admin"
}

output "django_admin_password" {
  description = "Djando Admin password"
  sensitive   = true
  value       = google_secret_manager_secret_version.django_admin_password.secret_data
}

output "usage" {
  description = "Next steps for usage"
  sensitive   = true
  value       = <<-EOF
    This deployment is now ready for use!
    ${local.firebase_url}
    API Login:
    ${google_cloud_run_v2_service.server.uri}/admin
    Username: admin
    Password: ${google_secret_manager_secret_version.django_admin_password.secret_data}
    EOF
}
