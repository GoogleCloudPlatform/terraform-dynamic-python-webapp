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


resource "google_compute_network" "default" {
  name = "default"
}

resource "google_compute_instance" "initialize" {
  count = var.init ? 1 : 0
  depends_on = [
    google_project_service.enabled,
    google_sql_database_instance.postgres,
    google_cloud_run_v2_job.setup,
    google_cloud_run_v2_job.client,
    google_compute_network.default,
  ]

  name         = "head-start-initialize"
  machine_type = "n1-standard-1"
  zone         = var.zone

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    email  = google_service_account.compute[0].email
    scopes = ["cloud-platform"] # TODO: Restrict?
  }

  metadata_startup_script = <<EOT
#!/bin/bash

echo "Running init database migration"
gcloud beta run jobs execute ${google_cloud_run_v2_job.setup.name} --wait --project ${var.project_id} --region ${var.region}


echo "Running client deploy"
gcloud beta run jobs execute ${google_cloud_run_v2_job.client.name} --wait --project ${var.project_id} --region ${var.region}

# shutdown -h now
EOT
}