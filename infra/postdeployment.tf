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

resource "google_compute_network" "gce_init" {
  count = var.init ? 1 : 0

  name                            = var.random_suffix ? "gce-init-network-${random_id.suffix.hex}" : "gce-init-network"
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  project                         = var.project_id
  delete_default_routes_on_create = false
  mtu                             = 0

  depends_on = [google_project_service.enabled]
}

resource "google_compute_subnetwork" "gce_init" {
  count = var.init ? 1 : 0

  name          = var.random_suffix ? "subnet-gce-init-${random_id.suffix.hex}" : "subnet-gce-init"
  network       = google_compute_network.gce_init[0].id
  ip_cidr_range = "10.10.10.0/24"
  region        = var.region

  depends_on = [google_project_service.enabled]
}

resource "google_compute_instance" "gce_init" {
  count = var.init ? 1 : 0

  depends_on = [
    google_project_service.enabled,
    google_sql_database_instance.postgres,
    google_cloud_run_v2_job.setup,
    google_cloud_run_v2_job.client,
  ]

  name           = var.random_suffix ? "head-start-initialize-${random_id.suffix.hex}" : "head-start-initialize"
  machine_type   = "n1-standard-1"
  zone           = var.zone
  desired_status = "RUNNING"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.gce_init[0].self_link
    subnetwork = google_compute_subnetwork.gce_init[0].self_link

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
curl -X PURGE "${local.firebase_url}/"

echo "Warm up API"
curl ${local.server_url}/api/products/?warmup

shutdown -h now
EOT
}


resource "google_compute_instance" "placeholder_init" {
  count = var.init ? 1 : 0

  depends_on = [
    google_project_service.enabled,
    google_cloud_run_v2_job.placeholder,
  ]

  name           = var.random_suffix ? "placeholder-initialize-${random_id.suffix.hex}" : "placeholder-initialize"
  machine_type   = "n1-standard-1"
  zone           = var.zone
  desired_status = "RUNNING"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.gce_init[0].self_link
    subnetwork = google_compute_subnetwork.gce_init[0].self_link

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    email  = google_service_account.compute[0].email
    scopes = ["cloud-platform"] # TODO: Restrict??
  }

  metadata_startup_script = <<EOT
#!/bin/bash

echo "Running placeholder deployment"
gcloud beta run jobs execute ${google_cloud_run_v2_job.placeholder.name} --wait --project ${var.project_id} --region ${var.region}
curl -X PURGE "${local.firebase_url}/"

shutdown -h now
EOT
}
