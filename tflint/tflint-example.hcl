#----------------------------------------------------------
# Warn about deprecated syntax, unused declarations
#----------------------------------------------------------
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

#----------------------------------------------------------
# TFLint ruleset plugin for Terraform Provider for Azure (Resource Manager)
# https://github.com/terraform-linters/tflint-ruleset-azurerm
#----------------------------------------------------------
plugin "azurerm" {
    enabled = true
    version = "0.25.1"
    source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

#----------------------------------------------------------
# TFLint ruleset plugin for Terraform AWS Provider
# https://github.com/terraform-linters/tflint-ruleset-aws
#----------------------------------------------------------
plugin "aws" {
    enabled = true
    version = "0.27.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

config {
  format = "default"
  plugin_dir = "~/.tflint.d/plugins"

  module = false

  force = true
}