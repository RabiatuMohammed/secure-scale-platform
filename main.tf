resource "azurerm_resource_group" "platform" {
  name = "rg-${var.environment}"
  location = var.location
  tags = local.common_tags
}

locals {
  common_tags   = {
    Environment = var.environment
    Project     = "Security-Platform"
    ManagedBy   = "Terraform"
  }
}