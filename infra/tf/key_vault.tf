data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kvault" {
  name                = "${var.environment}-key"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "get",
      "list",
      "delete",
      "purge",
      "recover"
    ]
  }
}

resource "random_string" "password" {
  length  = 32
  special = true
}

resource "azurerm_key_vault_secret" "secret" {
  name         = "${var.environment}-secret"
  value        = random_string.password.result
  key_vault_id = azurerm_key_vault.kvault.id
}