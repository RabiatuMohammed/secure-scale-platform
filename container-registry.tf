resource "azurerm_container_registry" "platform" {
  name                     = "acr${var.environment}platform"
  resource_group_name      = azurerm_resource_group.platform.name
  location                 = azurerm_resource_group.platform.location
  sku                      = "Premium"
  admin_enabled            = false


  network_rule_set {
    default_action              = "Deny"


    dynamic "ip_rule"   {
       for_each                    = var.allowed_ips
      content {
         action                    = "Allow"
        ip_range                   = ip_rule.value
      }
    }

  }

  network_rule_bypass_option = "AzureServices"

  public_network_access_enabled = false



  identity {
    type                        = "UserAssigned"
    identity_ids                = [azurerm_user_assigned_identity.platform.id]
  }

  tags           = local.common_tags

}

resource "azurerm_private_endpoint" "acr" {
  name                             = "pe-acr-${var.environment}"
  location                         = azurerm_resource_group.platform.location
  resource_group_name              = azurerm_resource_group.platform.name
  subnet_id                        = azurerm_subnet.private_endpoints.id


  private_service_connection {
    name                           = "psc-acr-${var.environment}"
    private_connection_resource_id = azurerm_container_registry.platform.id
    is_manual_connection           = false
    subresource_names              = ["registry"]

  }


  private_dns_zone_group {
    name          = "privatednszonegroup"
    private_dns_zone_ids = [azurrerm_private_dns_zone.acr.id]
  }

  tags         = local.common_tags

}

resource "azurerm_monitor_diagnostic_setting" "acr" {
  name                          = "acr-diagnostic"
  target_resource_id            = azurerm_container_registry.platform.id
  log_analytics_workspace_id    = azurerm_log_analytics_workspace.platform.id

  
  enabled_log {
    category  = "ContainerRegisterRepositoryEvents"

  }

  enabled_log {
    category = "ContainerRegisterLoginEvents"

  }

  metric {
    category = "AllMetrics"  
     enabled   = true
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope       = azurerm_container_registry.platform.id
  role_definition_name = "AcrPull"
  principal_id = azurerm_kubernetes_cluster.platform.kubelet_identity[0].object_id
}

resource "azurerm_private_dns_zone" "acr" {
  name                  = "privatelink.azurecr.io"
  resource_group_name   = azurerm_resource_group.platform.name
  tags                  = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                    = "pdnsz-vnet-link-acr"
  resource_group_name     = azurerm_resource_group.platform.name
  private_dns_zone_name   = azurerm_private_dns_zone.acr.name
  virtual_network_id      = azurerm_virtual_network.platform.id
  registration_enabled    = false
  tags                    = local.common_tags
}