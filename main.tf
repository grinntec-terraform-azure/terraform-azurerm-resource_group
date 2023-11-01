/**
 * # Azure Resource Group Terraform Module
 *
 * This Terraform module is designed to provision an Azure Resource Group.
 *
 * ## Features:
 * - **Terraform Version Compatibility**: This module requires Terraform version 1.0 or newer.
 * - **Azure Provider Version**: It uses the AzureRM provider version 3.0 or any newer version below 4.0.
 * - **Tagging**: Allows tagging of resources with `app` and `env` tags.
 * - **Resource Group**: Provisions an Azure Resource Group with a name pattern of `rg-{app_name}-{environment}`.
 * - **Location Validation**: Ensures that the provided location is one of 'westeurope', 'eastus', or 'southeastasia'.
 * - **Environment Validation**: Validates that the environment is either 'dev', 'test', or 'prod'.
 * - **App Name Validation**: Ensures the app name starts with a letter, ends with a letter or number, and is between 1 and 90 characters.
 * - **Outputs**: Outputs the name and location of the provisioned resource group.
 *
 * ## Usage:
 * To use this module, provide values for the required variables: `location`, `environment`, and `app_name`.
 * Once applied, the module will provision the specified Azure Resource Group and output its name and location.
 *
 * Note: Always ensure you're using the correct Terraform and provider versions before applying.
 */

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
}

############################################################
# LOCALS
############################################################
locals {
  common_tags = {
    appname    = var.app_name
    uai        = var.uai
    env        = var.environment
    created_by = var.created_by
  }

  date_tags = {
    created_date = timestamp()
  }

  common_name = "${var.uai}-${var.app_name}-${var.environment}"
}

############################################################
# RESOURCES
############################################################
resource "azurerm_resource_group" "this" {
  name     = "${local.common_name}-rg"
  location = var.location
  tags     = merge(local.common_tags, local.date_tags)
  lifecycle {
    ignore_changes = [tags["created_date"]]
  }
}

resource "azurerm_management_lock" "this" {
  count      = var.enable_lock ? 1 : 0
  name       = "${azurerm_resource_group.this.name}-lock"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "Locking the resource group to prevent accidental deletion to all the resources within"
}


############################################################
# VARIABLES
############################################################
// These are considered default variables required for most resources in Azure
variable "azure_subscription_id" {
  description = "Azure Subscription ID for the network. It should be in a valid GUID format."
  type        = string

  validation {
    condition     = can(regex("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$", var.azure_subscription_id))
    error_message = "The Azure Subscription ID must be in a valid GUID format (e.g., 12345678-1234-1234-1234-123456789012)."
  }
}

variable "app_name" {
  type        = string
  description = <<EOT
  (Required) Name of the workload. It must start with a letter and end with a letter or number.

  Example:
  - applicationx
  EOT

  validation {
    condition     = length(var.app_name) <= 90 && can(regex("^[a-zA-Z].*[a-zA-Z0-9]$", var.app_name))
    error_message = "app_name is invalid. 'app_name' must be between 1 and 90 characters, start with a letter, and end with a letter or number."
  }
}

variable "uai" {
  description = "Unique Application Identifier (UAI) of the application. The UAI format must be 'uai' followed by 7 digits (e.g., uai3033130)."
  type        = string

  validation {
    condition     = can(regex("^uai[0-9]{7}$", var.uai))
    error_message = "The UAI must start with 'uai' and be followed by 7 digits."
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
    condition     = can(regex("^(dev|test|prod)$", var.environment))
    error_message = "Environment is invalid. Valid options are 'dev', 'test', or 'prod'."
  }
}

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
    condition     = can(regex("^(westeurope|eastus|southeastasia)$", var.location))
    error_message = "Location is invalid. Options are 'westeurope', 'eastus', or 'southeastasia'."
  }
}

variable "created_by" {
  type        = string
  description = <<EOT
  (Required) The Single Sign-On (SSO) ID of the person creating this resource. 
  The SSO ID must be a 9-digit numerical value.
  
  Example:
  - 123456789
  EOT

  validation {
    condition     = can(regex("^[0-9]{9}$", var.created_by))
    error_message = "The SSO ID is invalid. It must be a 9-digit numerical value."
  }
}

variable "enable_lock" {
  type        = bool
  description = "Enable or disable a lock on the resource group"
  default     = false
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