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

resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id

  depends_on = [google_project_service.enabled]
}

resource "google_firebase_hosting_site" "client" {

  # By default, a firebase site will be named "project_id". Only create a custom site if using suffixes
  count = var.random_suffix ? 1 : 0

  provider = google-beta
  project  = google_firebase_project.default.project
  site_id  = "${var.project_id}-${random_id.suffix.hex}"

  depends_on = [google_project_service.enabled]
}
