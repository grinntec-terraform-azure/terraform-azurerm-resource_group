![Latest Tag](https://img.shields.io/badge/Tag-PLACEHOLDER-blue)



<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.75.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | (Required) Name of the workload.<br><br>  Example:<br>  - applicationx | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | (Required) Describe the environment type.<br><br>  Options:<br>  - dev<br>  - test<br>  - prod | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Location of where the workload will be managed.<br><br>  Options:<br>  - westeurope<br>  - eastus<br>  - southeastasia | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_location"></a> [location](#output\_location) | The location of the resource |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
<!-- END_TF_DOCS -->
