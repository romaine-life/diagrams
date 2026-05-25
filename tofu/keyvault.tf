resource "azurerm_key_vault" "main" {
  name                       = var.key_vault_name
  resource_group_name        = azurerm_resource_group.diagrams.name
  location                   = azurerm_resource_group.diagrams.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 7

  tags = {
    app       = "diagrams"
    managedBy = "diagrams"
    purpose   = "app-secrets"
  }
}
