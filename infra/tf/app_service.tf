resource "azurerm_app_service_plan" "example" {
  name                = "${var.environment}-service-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  # Define Linux as Host OS
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "blazordemo123"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  app_settings = {
    # Settings for private Container Registires  
    DOCKER_REGISTRY_SERVER_URL      = "https://hub.docker.com/"
  }

  site_config {
    linux_fx_version          = "DOCKER|onlylight291998/docker_dotnet:latest"
    always_on                 = "true"
  }
}