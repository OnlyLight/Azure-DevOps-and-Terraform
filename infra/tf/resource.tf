resource "azurerm_resource_group" "example" {
  name = "${var.environment}-rg"
  location = var.region
}
