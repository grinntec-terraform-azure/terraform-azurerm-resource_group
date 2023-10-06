# Provider configuration in the root module
provider "azurerm" {
  features {}
  # You can also specify other provider configurations like `subscription_id`, `client_id`, etc.
}

# Create the resource
module "azure_resource_group" {
  source = "./path_to_your_module_directory"  # Adjust this path to where your module is located

  # Provide values for the module's variables
  app_name   = "myapp"
  environment = "dev"
  location   = "westeurope"
}

# Outputs from the module
output "resource_group_name" {
  description = "The name of the resource group created by the module"
  value       = module.azure_resource_group.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group created by the module"
  value       = module.azure_resource_group.location
}


