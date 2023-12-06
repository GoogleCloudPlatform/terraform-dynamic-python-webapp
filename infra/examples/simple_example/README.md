# Simple Example

This example illustrates how to use the `dynamic-python-webapp` module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| region | Google Cloud Region | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| client\_job\_name | Client Cloud Run job name |
| firebase\_url | Firebase URL |
| server\_service\_name | Server Cloud Run service name |
| usage | Connection details for the project |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
