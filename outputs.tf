output "resource_group_name" {
  value   = azurerm_resource_group.platform.name
}

output "aks_cluster_name" {
  value  = azurerm_kubernetes_cluster.platform.name
}

output "acr_login_server" {
  value  = azurerm_container_registry.platform.login_server
}

output "key_vault_uri" {
  value    = azurerm_key_vault.platform.vault_uri
}

output "application_gateway_name" {
  value    = azurerm_application_gateway.platform.name
}

output "log_analytics_workspace_id" {
  value    = azurerm_log_analytics_workspace.platform.id
}

output "vnet_name" {
  value    = azurerm_virtual_network.platform.name
}

output "vnet_id" {
  value    = azurerm_virtual_network.platform.id
}

output "subnet_ids" {
  value    = {
    aks       = azurerm_subnet.aks.id
    appgw     = azurerm_subnet.appgw.id
    endpoints = azurerm_subnet.private_endpoints.id
  }
}