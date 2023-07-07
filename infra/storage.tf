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

resource "google_storage_bucket" "media" {
  name = var.random_suffix ? "media-${var.project_id}-${random_id.suffix.hex}" : "media-${var.project_id}"

  location      = var.region
  storage_class = "REGIONAL"
  force_destroy = true

  # Avoid conflict with constraints/storage.uniformBucketLevelAccess.
  # This is recommended: https://cloud.google.com/storage/docs/uniform-bucket-level-access#should-you-use
  uniform_bucket_level_access = true

  labels = var.labels
}

resource "google_storage_bucket_iam_member" "server" {
  bucket = google_storage_bucket.media.name
  member = local.server_SA
  role   = "roles/storage.admin"
}

resource "google_storage_bucket_iam_member" "automation" {
  bucket = google_storage_bucket.media.name
  member = local.automation_SA
  role   = "roles/storage.admin"
}
