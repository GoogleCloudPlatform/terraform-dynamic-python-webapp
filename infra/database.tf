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

# Cloud SQL Database

## Instance

resource "google_sql_database_instance" "postgres" {
  name             = var.random_suffix ? "${var.instance_name}-${random_id.suffix.hex}" : var.instance_name
  database_version = "POSTGRES_14"
  project          = var.project_id
  region           = var.region

  settings {
    tier        = "db-custom-2-4096" # 2 CPU, 4GB Memory
    user_labels = var.labels
  }
  depends_on = [google_project_service.enabled]

}

## Database
resource "google_sql_database" "database" {
  name     = var.random_suffix ? "${var.database_name}-${random_id.suffix.hex}" : var.database_name
  instance = google_sql_database_instance.postgres.name
}

## Database User
## Details used in Django config settings
# NOTE: users created this way automatically gain cloudsqladmin rights.
resource "google_sql_user" "django" {
  name     = var.random_suffix ? "${var.database_username}-${random_id.suffix.hex}" : var.database_username
  instance = google_sql_database_instance.postgres.name
  password = random_password.database_user_password.result
}
resource "random_password" "database_user_password" {
  length  = 30
  special = false
}
