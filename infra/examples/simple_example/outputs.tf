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

output "usage" {
  sensitive   = true
  description = "Connection details for the project"
  value       = module.dynamic-python-webapp.usage
}

output "firebase_url" {
  description = "Firebase URL"
  value       = module.dynamic-python-webapp.firebase_url
}

output "server_service_name" {
  description = "Server Cloud Run service name"
  value       = module.dynamic-python-webapp.server_service_name
}

output "client_job_name" {
  description = "Client Cloud Run job name"
  value       = module.dynamic-python-webapp.client_job_name
}
