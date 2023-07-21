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

# Secret Manager values

## Django Admin Password
resource "random_password" "django_admin_password" {
  length  = 32
  special = false
}

resource "google_secret_manager_secret" "django_admin_password" {
  secret_id = var.random_suffix ? "django_admin_password-${random_id.suffix.hex}" : "django_admin_password"
  replication {
    # Avoid conflict with constraints/gcp.resourceLocations for Secret Manager.
    # https://cloud.google.com/secret-manager/docs/choosing-replication
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [module.project_services]
}

resource "google_secret_manager_secret_iam_binding" "django_admin_password" {
  secret_id = google_secret_manager_secret.django_admin_password.id
  role      = "roles/secretmanager.secretAccessor"
  members   = [local.automation_SA]
}

resource "google_secret_manager_secret_version" "django_admin_password" {
  secret      = google_secret_manager_secret.django_admin_password.id
  secret_data = random_password.django_admin_password.result
}

## Django Secret Key

resource "random_password" "django_secret_key" {
  special = false
  length  = 50
}
resource "google_secret_manager_secret" "django_settings" {
  secret_id = var.random_suffix ? "django_settings-${random_id.suffix.hex}" : "django_settings"
  replication {
    # Avoid conflict with constraints/gcp.resourceLocations for Secret Manager.
    # https://cloud.google.com/secret-manager/docs/choosing-replication
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [module.project_services]
}

## Django configuration settings
resource "google_secret_manager_secret_version" "django_settings" {
  secret      = google_secret_manager_secret.django_settings.id
  secret_data = <<EOF
DATABASE_URL="postgres://${google_sql_user.django.name}:${google_sql_user.django.password}@//cloudsql/${google_sql_database_instance.postgres.project}:${google_sql_database_instance.postgres.region}:${google_sql_database_instance.postgres.name}/${google_sql_database.database.name}"
GS_BUCKET_NAME="${google_storage_bucket.media.name}"
SECRET_KEY="${random_password.django_secret_key.result}"
EOF
}

resource "google_secret_manager_secret_iam_binding" "django_settings" {
  secret_id = google_secret_manager_secret.django_settings.id
  role      = "roles/secretmanager.secretAccessor"
  members   = [local.server_SA, local.automation_SA]
}
