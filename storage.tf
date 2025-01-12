resource "random_string" "unique" {
  length   = 6
  special  = false
  upper    = false
}

resource "azurerm_storage_account" "platform" {
  name                            = "st${var.environment}platform${random_string.unique.result}"
  resource_group_name             = azurerm_resource_group.platform.name
  location                        = azurerm_resource_group.platform.location
  account_kind                    = "StorageV2"
  account_tier                     = "Premium"
  account_replication_type        = "ZRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false


  tags = local.common_tags

identity {
  type = "UserAssigned"
  identity_ids = [azurerm_user_assigned_identity.platform.id]
}

network_rules {
  default_action             = "Deny"
  ip_rules                   = [var.container_registry_ip]
  virtual_network_subnet_ids = [azurerm_subnet.private_endpoints.id]
  bypass                     = ["AzureServices"]

}

blob_properties {
  versioning_enabled  = true
  change_feed_enabled = true


  delete_retention_policy {
    days = 30
  }

  container_delete_retention_policy {
    days = 30
  }

}

}

resource "azurerm_monitor_diagnostic_setting" "storage" {
  name                        = "storage-diagnostic"
  target_resource_id          = azurerm_storage_account.platform.id
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.platform.id


  metric {
    category = "Transaction"
    enabled  = true


  }
}

resource "azurerm_storage_container" "platform_config" {
  name                  = "platform-config"
  storage_account_name =  azurerm_storage_account.platform.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "security_scan" {
  name                  = "security-scan"
  storage_account_name  = azurerm_storage_account.platform.name
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "storage" {
 name                   = "pe-storage-${var.environment}"
 location               = azurerm_resource_group.platform.location
 resource_group_name    = azurerm_resource_group.platform.name
 subnet_id              = azurerm_subnet.private_endpoints.id

private_service_connection {
  name                           = "psc-storage-${var.environment}"
  private_connection_resource_id = azurerm_storage_account.platform.id
  is_manual_connection           = false
  subresource_names              = ["blob"]
 } 
}


resource "azurerm_role_assignment" "storage_blob_contributor" {
  scope                 = azurerm_storage_account.platform.id
  role_definition_name  = "Storage Blob Data Contributor"
  principal_id          = azurerm_user_assigned_identity.platform.principal_id
}