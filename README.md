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

No input.

## Outputs

| Name | Description |
|------|-------------|
| firebase\_url | Firebase URL |

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

Refer to the [contribution guidelines](CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](SECURITY.md).
