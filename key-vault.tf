resource "random_string" "kv_unique" {
  length    = 6
  special   = false
  upper     = false
}

resource "azurerm_key_vault" "platform" {
name                       = "kv-${var.environment}-${random_string.kv_unique.result}"
location                   = azurerm_resource_group.platform.location
resource_group_name        = azurerm_resource_group.platform.name
tenant_id                  = data.azurerm_client_config.current.tenant_id
sku_name                   = "premium"
soft_delete_retention_days = 90
purge_protection_enabled   = true
enable_rbac_authorization  = true

network_acls {
  bypass                   = "AzureServices"
  default_action           = "Deny"
  virtual_network_subnet_ids = [azurerm_subnet.private_endpoints.id]
  ip_rules                = [var.container_registry_ip]
}

tags                     = local.common_tags
}


resource "azurerm_private_endpoint" "keyvault" {
  name                   = "pe-kv-${var.environment}"
  location               = azurerm_resource_group.platform.location
  resource_group_name    = azurerm_resource_group.platform.name
  subnet_id              = azurerm_subnet.private_endpoints.id


  private_service_connection {
    name                           = "psc-kv-${var.environment}"
    private_connection_resource_id = azurerm_key_vault.platform.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

resource "azurerm_role_assignment" "kv_admin" {
  scope                            = azurerm_key_vault.platform.id
  role_definition_name             = "Key Vault Administrator"
  principal_id                     = azurerm_user_assigned_identity.platform.principal_id
}

resource "azurerm_role_assignment" "kv_secrets_user" {
 scope                             = azurerm_key_vault.platform.id
 role_definition_name              = "Key Vault Secrets User"
 principal_id                      = azurerm_kubernetes_cluster.platform.kubelet_identity[0].object_id

}

resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                             = "kv-diagnostics"
  target_resource_id               = azurerm_key_vault.platform.id
  log_analytics_workspace_id       = azurerm_log_analytics_workspace.platform.id


enabled_log {
  category = "AuditEvent"
 }

enabled_log {
  category  = "AzurePolicyEvaluationDetails"
  }

metric {
  category = "AllMetrics"
  enabled  = true
  }
}

resource "azurerm_key_vault_certificate" "platform" {
  name          = "appgw-cert-${var.environment}"
  key_vault_id  = azurerm_key_vault.platform.id

  certificate_policy {
   issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject     = "CN=*.${var.environment}.platform"
      validity_in_months = 12
    }
  }
tags           = local.common_tags
}