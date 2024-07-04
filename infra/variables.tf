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

# Standard values

variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "region" {
  default     = "us-central1"
  type        = string
  description = "Google Cloud Region"
}

# HSA

# tflint-ignore: terraform_unused_declarations
variable "zone" {
  type        = string
  description = "GCP zone for provisioning zonal resources."
  default     = "us-central1-c"
}

variable "labels" {
  type        = map(string)
  description = "A set of key/value label pairs to assign to the resources deployed by this blueprint."
  default     = {}
}

variable "random_suffix" {
  description = "Add random suffix to VM name"
  type        = string
  default     = true
}

variable "enable_apis" {
  type        = bool
  description = "Whether or not to enable underlying apis in this solution."
  default     = true
}

variable "init" {
  type        = bool
  description = "Initialize database?"
  default     = true
}

variable "image_version" {
  type        = string
  default     = "v1.10.3"
  description = "Version of the container image to use"
}

variable "client_image_host" {
  type        = string
  default     = "hsa-public/containers/terraform-python-dynamic-webapp"
  description = "Artifact Registry that hosts the client image (PROJECT_ID/registry)"
}

variable "server_image_host" {
  type        = string
  default     = "hsa-public/containers/terraform-python-dynamic-webapp"
  description = "Artifact Registry that hosts the server image (PROJECT_ID/registry)"
}

# Optional customisation

variable "instance_name" {
  type        = string
  default     = "psql"
  description = "Cloud SQL Instance name"
}

variable "service_name" {
  type        = string
  default     = "server"
  description = "Cloud Run service name"
}

variable "database_name" {
  type        = string
  default     = "django"
  description = "Cloud SQL database name"
}

variable "database_username" {
  type        = string
  default     = "server"
  description = "Cloud SQL database name"
}
