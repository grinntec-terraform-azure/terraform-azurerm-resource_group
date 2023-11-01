
## 1.0.0 - 2023-11-01
- working

### Diff:
```
diff --git a/example/.terraform.lock.hcl b/example/.terraform.lock.hcl
index 54f4fc7..19c6de4 100644
--- a/example/.terraform.lock.hcl
+++ b/example/.terraform.lock.hcl
@@ -7,0 +8 @@ provider "registry.terraform.io/hashicorp/azurerm" {
+    "h1:b7wCNsV0HyJalcmjth7Y4nSBuZqEjbA0Phpggoy4bLE=",
diff --git a/example/main.tf b/example/main.tf
index 16a2a74..02aed1b 100644
--- a/example/main.tf
+++ b/example/main.tf
@@ -2,0 +3,2 @@
+# This block configures the target Azure tenant and subsciption
+# and provides the credentials required to manage resources there.
@@ -4 +6 @@
-# Provider configuration in the root module
+# Azure Provider Configuration
@@ -5,0 +8,6 @@ provider "azurerm" {
+  features {}
+  client_id       = var.client_id
+  client_secret   = var.client_secret
+  subscription_id = var.azure_subscription_id
+  tenant_id       = var.azure_tenant_id
+}
@@ -7,5 +15,4 @@ provider "azurerm" {
-  # Specify specific parts of the target environment if not configured as environment variables
-  #subscription_id = "your-subscription-id" // The target Azure subscription
-  #client_id = "your-client-id" // Avoid hard-coding security credentials
-  #client_secret = "your-client-secret" // Avoid hard-coding security credentials
-  #tenant_id = "your-tenant-id" // The Azure AD tenant
+/*
+The following variables are setup on the client workstation
+workstation as environment variables and loaded as part of
+the provider setup.
@@ -13,2 +20,5 @@ provider "azurerm" {
-  # Features block is required for azurerm provider
-  features {}
+'TF_VAR_client_id' is the service principal client ID
+'TF_VAR_client_secret' is the password of the service principal
+*/
+variable "client_id" {
+  description = "Service Principal Client ID"
@@ -16,0 +27,22 @@ provider "azurerm" {
+variable "client_secret" {
+  description = "Service Principal Client Secret"
+  sensitive   = true # This will ensure the value isn't shown in logs or console output
+}
+
+/*
+CHANGE THIS VALUE
+This sets the target Azure subscription
+*/
+variable "azure_subscription_id" {
+  description = "Azure Subscription ID"
+  default     = "c714dba2-7aff-402d-ab05-7e2d57532a86"
+}
+
+/*
+DO NOT CHANGE THIS VALUE
+It sets the Azure tenant ID which is the same for all Azure subscriptions
+*/
+variable "azure_tenant_id" {
+  description = "Azure Active Directory Tenant ID"
+  default     = "17452008-ed27-47bc-b363-3bcb5faa883d" # DO NOT CHANGE THIS VALUE
+}
@@ -21,10 +53,11 @@ provider "azurerm" {
-# Backend configuration for remote state in Azure Blob Storage
-#terraform {
-#  backend "azurerm" {
-#    resource_group_name   = "terraform-state"
-#    storage_account_name  = "tfstateaccountsandbox"
-#    container_name        = "tfstatecontainer"
-#    key                   = "main.terraform.tfstate"
-#  }
-#}
-
+terraform {
+  # Backend configuration for remote state in Azure Blob Storage
+  backend "azurerm" {
+    resource_group_name  = "terraform-state"
+    storage_account_name = "tfstateaccountsandbox" // Enter the Azure storage account name that hosts the Terraform state; usually as format '{xyzgrvnet}
+    container_name       = "tfstatecontainer"
+    key                  = "uai1234567-example-dev-resource_group.tfstate" // Format as '{uai}-{app_name}-{environment}-{resource}.tfstate'
+    subscription_id      = "c714dba2-7aff-402d-ab05-7e2d57532a86"          // Enter the Azure subscription ID
+    tenant_id            = "17452008-ed27-47bc-b363-3bcb5faa883d"          // Enter the Azure tenant ID
+  }
+}
@@ -33 +66 @@ provider "azurerm" {
-# RESOURCE
+# MODULE
@@ -37 +70 @@ module "azure_resource_group" {
-  source = "../."
+  source = "../../terraform-azurerm-resource_group"
@@ -40,3 +73,8 @@ module "azure_resource_group" {
-  app_name    = "myapp"
-  environment = "dev"
-  location    = "westeurope"
+  azure_subscription_id = var.azure_subscription_id
+  app_name              = "example"
+  uai                   = "uai1234567"
+  environment           = "dev"
+  location              = "westeurope"
+  created_by            = "123456789"
+  // Resource specific input variables
+  enable_lock = false
@@ -45 +82,0 @@ module "azure_resource_group" {
-
diff --git a/main.tf b/main.tf
index 47103e8..17742b2 100644
--- a/main.tf
+++ b/main.tf
@@ -23 +22,0 @@
-
@@ -48,3 +47,5 @@ locals {
-  tags = {
-    app = var.app_name
-    env = var.environment
+  common_tags = {
+    appname    = var.app_name
+    uai        = var.uai
+    env        = var.environment
+    created_by = var.created_by
@@ -52 +52,0 @@ locals {
-}
@@ -53,0 +54,6 @@ locals {
+  date_tags = {
+    created_date = timestamp()
+  }
+
+  common_name = "${var.uai}-${var.app_name}-${var.environment}"
+}
@@ -59 +65 @@ resource "azurerm_resource_group" "this" {
-  name     = "rg-${var.app_name}-${var.environment}"
+  name     = "${local.common_name}-rg"
@@ -61 +67,12 @@ resource "azurerm_resource_group" "this" {
-  tags     = local.tags
+  tags     = merge(local.common_tags, local.date_tags)
+  lifecycle {
+    ignore_changes = [tags["created_date"]]
+  }
+}
+
+resource "azurerm_management_lock" "this" {
+  count      = var.enable_lock ? 1 : 0
+  name       = "${azurerm_resource_group.this.name}-lock"
+  scope      = azurerm_resource_group.this.id
+  lock_level = "CanNotDelete"
+  notes      = "Locking the resource group to prevent accidental deletion to all the resources within"
@@ -67,0 +85,4 @@ resource "azurerm_resource_group" "this" {
+// These are considered default variables required for most resources in Azure
+variable "azure_subscription_id" {
+  description = "Azure Subscription ID for the network. It should be in a valid GUID format."
+  type        = string
@@ -69,2 +90,7 @@ resource "azurerm_resource_group" "this" {
-# Common variables
-variable "location" {
+  validation {
+    condition     = can(regex("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$", var.azure_subscription_id))
+    error_message = "The Azure Subscription ID must be in a valid GUID format (e.g., 12345678-1234-1234-1234-123456789012)."
+  }
+}
+
+variable "app_name" {
@@ -73 +99 @@ variable "location" {
-  (Required) Location of where the workload will be managed.
+  (Required) Name of the workload. It must start with a letter and end with a letter or number.
@@ -75,4 +101,2 @@ variable "location" {
-  Options:
-  - westeurope
-  - eastus
-  - southeastasia
+  Example:
+  - applicationx
@@ -82,2 +106,12 @@ variable "location" {
-    condition     = can(regex("^westeurope$|^eastus$|^southeastasia$", var.location))
-    error_message = "Location is invalid. Options are 'westeurope', 'eastus', or 'southeastasia'"
+    condition     = length(var.app_name) <= 90 && can(regex("^[a-zA-Z].*[a-zA-Z0-9]$", var.app_name))
+    error_message = "app_name is invalid. 'app_name' must be between 1 and 90 characters, start with a letter, and end with a letter or number."
+  }
+}
+
+variable "uai" {
+  description = "Unique Application Identifier (UAI) of the application. The UAI format must be 'uai' followed by 7 digits (e.g., uai3033130)."
+  type        = string
+
+  validation {
+    condition     = can(regex("^uai[0-9]{7}$", var.uai))
+    error_message = "The UAI must start with 'uai' and be followed by 7 digits."
@@ -99 +133 @@ variable "environment" {
-    condition     = can(regex("^dev$|^test$|^prod$", var.environment))
+    condition     = can(regex("^(dev|test|prod)$", var.environment))
@@ -104 +138 @@ variable "environment" {
-variable "app_name" {
+variable "location" {
@@ -107 +141 @@ variable "app_name" {
-  (Required) Name of the workload.
+  (Required) Location of where the workload will be managed.
@@ -108,0 +143,18 @@ variable "app_name" {
+  Options:
+  - westeurope
+  - eastus
+  - southeastasia
+  EOT
+
+  validation {
+    condition     = can(regex("^(westeurope|eastus|southeastasia)$", var.location))
+    error_message = "Location is invalid. Options are 'westeurope', 'eastus', or 'southeastasia'."
+  }
+}
+
+variable "created_by" {
+  type        = string
+  description = <<EOT
+  (Required) The Single Sign-On (SSO) ID of the person creating this resource. 
+  The SSO ID must be a 9-digit numerical value.
+  
@@ -110 +162 @@ variable "app_name" {
-  - applicationx
+  - 123456789
@@ -114,2 +166,2 @@ variable "app_name" {
-    condition     = length(var.app_name) <= 90 && can(regex("^[a-zA-Z].*[a-zA-Z0-9]$", var.app_name))
-    error_message = "app_name is invalid. 'app_name' must be between 1 and 90 characters, start with a letter, and end with a letter or number."
+    condition     = can(regex("^[0-9]{9}$", var.created_by))
+    error_message = "The SSO ID is invalid. It must be a 9-digit numerical value."
@@ -118,0 +171,6 @@ variable "app_name" {
+variable "enable_lock" {
+  type        = bool
+  description = "Enable or disable a lock on the resource group"
+  default     = false
+}
+
```


## 0.0.1 - 2023-10-06
- pre-prod testing

### Diff:
```
diff --git a/README.md b/README.md
index e69de29..9325185 100644
--- a/README.md
+++ b/README.md
@@ -0,0 +1,33 @@
+## Requirements

+

+| Name | Version |

+|------|---------|

+| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

+| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

+

+## Providers

+

+| Name | Version |

+|------|---------|

+| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |

+

+## Resources

+

+| Name | Type |

+|------|------|

+| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

+

+## Inputs

+

+| Name | Description | Type | Default | Required |

+|------|-------------|------|---------|:--------:|

+| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | (Required) Name of the workload.<br><br>  Example:<br>  - applicationx | `string` | n/a | yes |

+| <a name="input_environment"></a> [environment](#input\_environment) | (Required) Describe the environment type.<br><br>  Options:<br>  - dev<br>  - test<br>  - prod | `string` | n/a | yes |

+| <a name="input_location"></a> [location](#input\_location) | (Required) Location of where the workload will be managed.<br><br>  Options:<br>  - westeurope<br>  - eastus<br>  - southeastasia | `string` | n/a | yes |

+

+## Outputs

+

+| Name | Description |

+|------|-------------|

+| <a name="output_location"></a> [location](#output\_location) | The location of the resource |

+| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |

```

