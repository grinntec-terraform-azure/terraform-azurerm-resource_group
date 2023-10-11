############################################################
# TERRAFORM CONFIGURATION
############################################################
# This configuration sets the minimum required version for the Terraform binary.
# It ensures that older, potentially incompatible versions aren't used.
# This code requires at least version 1.0 but supports all newer versions.
#
# The Azure provider version should be at least 3.0.
# This allows any minor or patch version above 3.0 but below 4.0.
terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
#}





############################################################
# LOCALS
############################################################
locals {
  tags = {
    app = var.app_name
    env = var.environment
  }
}


############################################################
# RESOURCES
############################################################
resource "azurerm_resource_group" "this" {
  name     = "rg-${var.app_name}-${var.environment}"
  location = var.location
  tags     = local.tags
}


############################################################
# VARIABLES
############################################################
variable "location" {
  type        = string
  description = <<EOT
  (Required) Location of where the workload will be managed.

  Options:
  - westeurope
  - eastus
  - southeastasia
  EOT

  validation {
    condition     = can(regex("^westeurope$|^eastus$|^southeastasia$", var.location))
    error_message = "Location is invalid. Options are 'westeurope', 'eastus', or 'southeastasia'"
  }
}

variable "environment" {
  type        = string
  description = <<EOT
  (Required) Describe the environment type.

  Options:
  - dev
  - test
  - prod
  EOT

  validation {
    condition     = can(regex("^dev$|^test$|^prod$", var.environment))
    error_message = "Environment is invalid. Valid options are 'dev', 'test', or 'prod'."
  }
}

variable "app_name" {
  type        = string
  description = <<EOT
  (Required) Name of the workload.

  Example:
  - applicationx
  EOT

  validation {
    condition     = length(var.app_name) <= 90 && can(regex("^[a-zA-Z].*[a-zA-Z0-9]$", var.app_name))
    error_message = "app_name is invalid. 'app_name' must be between 1 and 90 characters, start with a letter, and end with a letter or number."
  }
}


############################################################
# OUTPUTS
############################################################
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "The location of the resource"
  value       = azurerm_resource_group.this.location
}