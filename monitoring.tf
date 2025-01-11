resource "azurerm_log_analytics_workspace" "platform" {
  name                          = "law-${var.environment}-platform"
  location                      =  azurerm_resource_group.platform.location
  resource_group_name           = azurerm_resource_group.platform.name
  retention_in_days             = 90
  sku                           = "PerGB2018"


tags     = local.common_tags

}

resource "azurerm_application_insights" "platform" {
  name                        = "ai-${var.environment}-platform"
  location                    = azurerm_resource_group.platform.location
  resource_group_name         = azurerm_resource_group.platform.name
  application_type            = "web"
  workspace_id                = azurerm_log_analytics_workspace.platform.id



  tags     = local.common_tags

}

resource "azurerm_monitor_action_group" "critical" {
  name                        = "ag-critical-${var.environment}"
  resource_group_name         = azurerm_resource_group.platform.name
  short_name                  = "critical"


  email_receiver {
    name                     = "platform-team"
    email_address            = var.alert_email
  }
}

resource "azurerm_monitor_metric_alert" "platform" {
  name                       = "alert-platform-${var.environment}"
  resource_group_name        = azurerm_resource_group.platform.name
  scopes                     = [azurerm_kubernetes_cluster.platform.id]
  description                = "Alert when platform metrics exceed thresholds"



  criteria {
    metric_namespace         = "Microsoft.ContainerService/managedClusters"
    metric_name              = "node_cpu_usage_percentage"
    aggregation              = "Average"
    operator                 = "GreaterThan"
    threshold                = 80

  }



  action {
    action_group_id         = azurerm_monitor_action_group.critical.id
  }
}
