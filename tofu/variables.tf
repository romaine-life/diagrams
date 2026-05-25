variable "location" {
  description = "Azure region where the resource group will be created"
  type        = string
  default     = "westus2"
}

variable "key_vault_name" {
  description = "Diagrams-owned Key Vault for app runtime secrets."
  type        = string
  default     = "ng6-diagrams"
}
