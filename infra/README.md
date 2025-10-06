# terraform-dynamic-python-webapp

## Description

### Tagline

This is an auto-generated module.

### Detailed

The resources/services/activations/deletions that this module will create/trigger are:
- Cloud Run
- Cloud SQL
- Firebase Hosting
- Secret Manager
- IAM
- Cloud Storage

### PreDeploy

To deploy this blueprint you must have an active billing account and billing permissions.

## Documentation

- [Hosting a Static Website](https://cloud.google.com/storage/docs/hosting-static-website)

## Usage

Basic usage of this module is as follows:

```

module "dynamic-python-webapp" {
  source = "."
  project_id = var.project_id
}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| client\_image\_host | Artifact Registry that hosts the client image (PROJECT\_ID/registry) | `string` | `"hsa-public/containers/terraform-python-dynamic-webapp"` | no |
| database\_name | Cloud SQL database name | `string` | `"django"` | no |
| database\_username | Cloud SQL database name | `string` | `"server"` | no |
| enable\_apis | Whether or not to enable underlying apis in this solution. | `bool` | `true` | no |
| image\_version | Version of the container image to use | `string` | `"v1.13.10"` | no |
| init | Initialize database? | `bool` | `true` | no |
| instance\_name | Cloud SQL Instance name | `string` | `"psql"` | no |
| labels | A set of key/value label pairs to assign to the resources deployed by this blueprint. | `map(string)` | `{}` | no |
| project\_id | Google Cloud Project ID | `string` | n/a | yes |
| random\_suffix | Add random suffix to VM name | `string` | `true` | no |
| region | Google Cloud Region | `string` | `"us-central1"` | no |
| server\_image\_host | Artifact Registry that hosts the server image (PROJECT\_ID/registry) | `string` | `"hsa-public/containers/terraform-python-dynamic-webapp"` | no |
| service\_name | Cloud Run service name | `string` | `"server"` | no |
| zone | GCP zone for provisioning zonal resources. | `string` | `"us-central1-c"` | no |

## Outputs

| Name | Description |
|------|-------------|
| client\_job\_name | Name of the Cloud Run Job, deploying the front end |
| django\_admin\_password | Django Admin password |
| django\_admin\_url | Django Admin URL |
| firebase\_url | Firebase URL |
| neos\_toc\_url | Neos Tutorial URL |
| server\_service\_name | Name of the Cloud Run service, hosting the server API |
| usage | Next steps for usage |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- roles/cloudbuild.builds.editor
- roles/cloudsql.admin
- roles/compute.admin
- roles/compute.networkAdmin
- roles/firebase.managementServiceAgent
- roles/firebasehosting.admin
- roles/iam.serviceAccountAdmin
- roles/iam.serviceAccountUser
- roles/pubsub.editor
- roles/resourcemanager.projectIamAdmin
- roles/run.admin
- roles/secretmanager.admin
- roles/storage.admin


The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- run.googleapis.com
- iam.googleapis.com
- artifactregistry.googleapis.com
- compute.googleapis.com
- sql-component.googleapis.com
- cloudbuild.googleapis.com
- secretmanager.googleapis.com
- firebase.googleapis.com
- config.googleapis.com
- cloudresourcemanager.googleapis.com
- sqladmin.googleapis.com


The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](../CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](../SECURITY.md).
