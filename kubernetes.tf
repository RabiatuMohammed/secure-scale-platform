resource "azurerm_kubernetes_cluster" "platform" {
  name                                = "aks-${var.environment}"
  location                            = azurerm_resource_group.platform.location
  resource_group_name                 = azurerm_resource_group.platform.name
  dns_prefix                          = "security-platform"
  tags                                = local.common_tags
  kubernetes_version                  = "1.27"
  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = false
  azure_policy_enabled                = true

  default_node_pool {
    name                 =  "system"
    vm_size              = "Standard_D4s_v3"
    vnet_subnet_id       = azurerm_subnet.backend.id
    min_count            = 3
    max_count            = 5 
    node_count           = 3


only_critical_addons_enabled = true


node_labels = {
  "security.platform/workload"  = "system"
  "environment"                 = var.environment
   
  }

 } 
 

azure_active_directory_role_based_access_control {
  azure_rbac_enabled  = true
  tenant_id           = var.tenant_id
}
  

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    dns_service_ip     = "10.0.0.10"
    service_cidr       = "10.0.0.0/16"
    load_balancer_sku  = "standard"
    outbound_type      = "userDefinedRouting"

    pod_cidr           = "10.244.0.0/16"
  }




    oms_agent {
      log_analytics_workspace_id    = azurerm_log_analytics_workspace.platform.id
    }

    monitor_metrics {
      annotations_allowed = ["*"]
      labels_allowed      = ["*"]
    }

    maintenance_window {
      allowed {
        day = "Sunday"
        hours = [1, 2, 3]
      }
    }

    key_vault_secrets_provider {
      secret_rotation_enabled = true
      secret_rotation_interval = "2m"
    }

    identity {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
    }
}

resource "azurerm_monitor_diagnostic_setting" "aks_diagnostics" {
  name                  =  "security-platform-diagnostics"
  target_resource_id    = azurerm_kubernetes_cluster.platform.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id
  


  enabled_log {
    category   = "kube-apiserver"
  }

  enabled_log {
    category  = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

}

