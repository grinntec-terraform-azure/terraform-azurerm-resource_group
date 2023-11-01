############################################################
# PROVIDER CONFIGURATION
# This block configures the target Azure tenant and subsciption
# and provides the credentials required to manage resources there.
############################################################
# Azure Provider Configuration
provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

/*
The following variables are setup on the client workstation
workstation as environment variables and loaded as part of
the provider setup.

'TF_VAR_client_id' is the service principal client ID
'TF_VAR_client_secret' is the password of the service principal
*/
variable "client_id" {
  description = "Service Principal Client ID"
}

variable "client_secret" {
  description = "Service Principal Client Secret"
  sensitive   = true # This will ensure the value isn't shown in logs or console output
}

/*
CHANGE THIS VALUE
This sets the target Azure subscription
*/
variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  default     = "c714dba2-7aff-402d-ab05-7e2d57532a86"
}

/*
DO NOT CHANGE THIS VALUE
It sets the Azure tenant ID which is the same for all Azure subscriptions
*/
variable "azure_tenant_id" {
  description = "Azure Active Directory Tenant ID"
  default     = "17452008-ed27-47bc-b363-3bcb5faa883d" # DO NOT CHANGE THIS VALUE
}

############################################################
# TERRAFORM CONFIGURATION
############################################################
terraform {
  # Backend configuration for remote state in Azure Blob Storage
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "tfstateaccountsandbox" // Enter the Azure storage account name that hosts the Terraform state; usually as format '{xyzgrvnet}
    container_name       = "tfstatecontainer"
    key                  = "uai1234567-example-dev-resource_group.tfstate" // Format as '{uai}-{app_name}-{environment}-{resource}.tfstate'
    subscription_id      = "c714dba2-7aff-402d-ab05-7e2d57532a86"          // Enter the Azure subscription ID
    tenant_id            = "17452008-ed27-47bc-b363-3bcb5faa883d"          // Enter the Azure tenant ID
  }
}

############################################################
# MODULE
############################################################
module "azure_resource_group" {
  #source = "git@github.com:grinntec-terraform-azure/terraform-azure-resource-group.git?ref=0.0.1"
  source = "../../terraform-azurerm-resource_group"

  # Provide values for the module's variables
  azure_subscription_id = var.azure_subscription_id
  app_name              = "example"
  uai                   = "uai1234567"
  environment           = "dev"
  location              = "westeurope"
  created_by            = "123456789"
  // Resource specific input variables
  enable_lock = false
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


