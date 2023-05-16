terraform {
  required_version = "1.4.6"

  backend "local" {
    path = "./.tfstate/terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }

    #azuread = {
    #  source = "hashicorp/azuread"
    #}
  }
}

provider "azurerm" {

  features {

    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = true // Preview feature
    }
  }


  subscription_id = var.azure_subscription_id // ARM_SUBSCRIPTION_ID
  tenant_id       = var.azure_tenant_id       // ARM_TENANT_ID
}

#provider "azuread" {
#  tenant_id = var.tenant_id
#}
