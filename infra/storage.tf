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

  location      = "us-central1"
  storage_class = "REGIONAL"
  force_destroy = true

  labels = var.labels
}

data "google_iam_policy" "mediaaccess" {

  binding {
    role    = "roles/storage.legacyBucketOwner"
    members = ["projectOwner:${var.project_id}", "projectEditor:${var.project_id}", local.server_SA, local.automation_SA]
  }
  binding {
    role    = "roles/storage.legacyBucketReader"
    members = ["projectViewer:${var.project_id}"]
  }
}

resource "google_storage_bucket_iam_policy" "policy" {
  bucket      = google_storage_bucket.media.name
  policy_data = data.google_iam_policy.mediaaccess.policy_data
}
