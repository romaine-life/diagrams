# Per-app workload identity for diagrams — replaces reuse of
# infra-shared-identity. Diagrams' backend/config.js only reaches into
# the app-owned Key Vault (no Cosmos, no App Configuration), so this identity
# only needs app-vault read access for the secrets the pod reads at startup:
#   - github-webhook-secret
#   - github-app-id
#   - github-app-private-key
#   - codex-queue-jwt-secret

data "azurerm_resource_group" "infra" {
  name = local.infra.resource_group_name
}

resource "azurerm_user_assigned_identity" "diagrams" {
  name                = "diagrams-identity"
  resource_group_name = data.azurerm_resource_group.infra.name
  location            = data.azurerm_resource_group.infra.location
}

resource "azurerm_role_assignment" "diagrams_app_keyvault" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.diagrams.principal_id
}

resource "azurerm_federated_identity_credential" "diagrams" {
  name                = "aks-diagrams"
  resource_group_name = local.infra.resource_group_name
  parent_id           = azurerm_user_assigned_identity.diagrams.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = local.aks_oidc_issuer_url
  subject             = "system:serviceaccount:diagrams:infra-shared"
}

output "diagrams_identity_client_id" {
  value       = azurerm_user_assigned_identity.diagrams.client_id
  description = "Pin into k8s/serviceaccount.yaml's azure.workload.identity/client-id annotation."
}
