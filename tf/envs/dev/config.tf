terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.1.3"
    }
    template = {
      source  = "hashicorp/template"
      version = "=2.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "=0.7.2"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-kpmg-we-dev-001"
    storage_account_name = "stkpmgdevopswedev001"
    container_name       = "kpmg-devops-we-dev-001"
    key                  = "terraform/we/kpmg-devops-we-dev.tfstate"
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {
  }
}