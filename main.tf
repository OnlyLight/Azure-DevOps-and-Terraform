terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "app" {
    name = "demo-rg"
    location = "Southeast Asia"
}

resource "azurerm_app_service_plan" "app" {
  name                = "service-plan"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  # Define Linux as Host OS
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app" {
  name                = "blazordemo123"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  app_service_plan_id = azurerm_app_service_plan.app.id

  app_settings = {
    # Settings for private Container Registires  
    DOCKER_REGISTRY_SERVER_URL      = "https://hub.docker.com/"
  }

  site_config {
    linux_fx_version          = "DOCKER|onlylight291998/docker_dotnet:latest"
    always_on                 = "true"
  }
}