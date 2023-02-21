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

variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "region" {
  default     = "us-central1"
  type        = string
  description = "Google Cloud Region"
}

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

variable "image_host_project" {
  type        = string
  default     = "avocano-images-tmp"
  description = "Google Cloud Project that hosts images"
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

resource "random_id" "suffix" {
  byte_length = 2
}


