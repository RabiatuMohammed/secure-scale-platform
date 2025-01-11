terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.75.0"
    }

    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.45.0"
    }
    
    random = {
      source = "hashicorp/random"
      version = "~> 3.5.1"
    }

    helm = {
        source = "hashicorp/helm"
        version = "~> 2.0"
    }
  }
  backend "azurerm" {
   resource_group_name = "rg-terraform-state"
   storage_account_name = "sttfstaterabmoh"
   container_name = "tfstate"
   key = "security-platform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }

    resource_group {
      prevent_deletion_if_contains_resources = true
    }

    virtual_machine {
      delete_os_disk_on_deletion = true
    }

    api_management {
      purge_soft_delete_on_destroy = true
    }
  }
}
  provider "azuread" {
    tenant_id = var.tenant_id
  }


data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}  
