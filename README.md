<!-- BEGIN_TF_DOCS -->
# Azure Resource Group Terraform Module

This Terraform module is designed to provision an Azure Resource Group.

## Features:
- **Terraform Version Compatibility**: This module requires Terraform version 1.0 or newer.
- **Azure Provider Version**: It uses the AzureRM provider version 3.0 or any newer version below 4.0.
- **Tagging**: Allows tagging of resources with `app` and `env` tags.
- **Resource Group**: Provisions an Azure Resource Group with a name pattern of `rg-{app_name}-{environment}`.
- **Location Validation**: Ensures that the provided location is one of 'westeurope', 'eastus', or 'southeastasia'.
- **Environment Validation**: Validates that the environment is either 'dev', 'test', or 'prod'.
- **App Name Validation**: Ensures the app name starts with a letter, ends with a letter or number, and is between 1 and 90 characters.
- **Outputs**: Outputs the name and location of the provisioned resource group.

## Usage:
To use this module, provide values for the required variables: `location`, `environment`, and `app_name`.
Once applied, the module will provision the specified Azure Resource Group and output its name and location.

Note: Always ensure you're using the correct Terraform and provider versions before applying.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | 3.75.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_name | (Required) Name of the workload.<br><br>  Example:<br>  - applicationx | `string` | n/a | yes |
| environment | (Required) Describe the environment type.<br><br>  Options:<br>  - dev<br>  - test<br>  - prod | `string` | n/a | yes |
| location | (Required) Location of where the workload will be managed.<br><br>  Options:<br>  - westeurope<br>  - eastus<br>  - southeastasia | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| location | The location of the resource |
| resource\_group\_name | The name of the resource group |
<!-- END_TF_DOCS -->