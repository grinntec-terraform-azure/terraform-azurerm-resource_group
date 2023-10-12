

<!-- BEGIN_TF_DOCS -->
![Version Badge](https://img.shields.io/badge/Tag-0.0.1-blue)

![Build and Test Workflow](https://github.com/grinntec-terraform-azure/terraform-azurerm-resource_group/workflows/terraform-module-scanner/badge.svg)

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
## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |
## Providers

| Name | Version |
|------|---------|
| azurerm | 3.75.0 |
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

# Examples
This is an example configuration module that would use this repository to create and manage the resource. Read the help text carefully to understand what you need to edit prior to running the code.

```hcl
############################################################
# PROVIDER CONFIGURATION
############################################################
# Provider configuration in the root module
provider "azurerm" {
  
  # Specify specific parts of the target environment if not configured as environment variables
    #subscription_id = "your-subscription-id" // The target Azure subscription
    #client_id = "your-client-id" // Avoid hard-coding security credentials
    #client_secret = "your-client-secret" // Avoid hard-coding security credentials
    #tenant_id = "your-tenant-id" // The Azure AD tenant
    
  # Features block is required for azurerm provider
  features {}
}


############################################################
# TERRAFORM CONFIGURATION
############################################################
# Backend configuration for remote state in Azure Blob Storage
terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-state"
    storage_account_name  = "tfstateaccountsandbox"
    container_name        = "tfstatecontainer"
    key                   = "main.terraform.tfstate"
  }
}


############################################################
# RESOURCE
############################################################
module "azure_resource_group" {
  source = "git@github.com:grinntec-terraform-azure/terraform-azure-resource-group.git?ref=0.0.1" # Adjust this path to where your module is located

  # Provide values for the module's variables
  app_name    = "myapp"
  environment = "dev"
  location    = "westeurope"
}


############################################################
# OUTPUTS
############################################################
output "resource_group_name" {
  description = "The name of the resource group created by the module"
  value       = module.azure_resource_group.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group created by the module"
  value       = module.azure_resource_group.location
}


```
<!-- END_TF_DOCS -->
