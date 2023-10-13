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
# Comment out if using
/*
terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-state"
    storage_account_name  = "tfstateaccountsandbox"
    container_name        = "tfstatecontainer"
    key                   = "main.terraform.tfstate"
  }
}
*/


############################################################
# RESOURCE
############################################################
module "azure_resource_group" {
  #source = "git@github.com:grinntec-terraform-azure/terraform-azure-resource-group.git?ref=0.0.1" // uncommen to use GitHub repo as source
  source =  "../" // This source is used for testing the plan using GitHub actions, not for production

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


