resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-${var.environment}"
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  allocation_method   = "Static"
  sku                 = "Premium"
  tags                = local.common_tags
}

resource "azurerm_web_application_firewall_policy" "platform" {
  name                = "waf-${var.environment}-platform"
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location


  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
       type    = "OWASP"
        version = "3.2"
    }
  }

  custom_rules {
    name       = "BlackKnownBadIPs"
    priority   = 1
    rule_type  = "MatchRule"


    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator           = "IPMatch"
      negation_condition = false
      match_values       = var.blocked_ip_addresses
    }
    action = "Block"
  }

  tags    = local.common_tags
}

resource "azurerm_application_gateway" "platform" {
  name                 = "agw-${var.environment}-platform"
  resource_group_name  = azurerm_resource_group.platform.name
  location             = azurerm_resource_group.platform.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name       = "gateway-ip-configuration"
    subnet_id  = azurerm_subnet.appgw.id
  }

  frontend_port {
    name   = "https-port"
    port   = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name     = "aks-backend-setting"
  }

  backend_http_settings {
    name                  = "aks-backend-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "aks-probe"
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "platform-cert"
    firewall_policy_id             = azurerm_web_application_firewall_policy.platform.id
  }



  ssl_certificate {
    name                = "platform-cert"
    key_vault_secret_id = azurerm_key_vault_certificate.platform.secret_id
  }

  request_routing_rule {
    name                        = "default-rule"
    rule_type                   = "Basic"
    priority                    = 1
    http_listener_name          = "https-listener"
    backend_address_pool_name   = "aks-backend-pool"
    backend_http_settings_name  = "aks-backend-settings"
  }

  probe {
    name                = "aks-probe"
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    protocol            = "Http"
    port                = 80
    path                = "/healthz"
  }


  identity {
    type              = "UserAssigned"
    identity_ids      = [azurerm_user_assigned_identity.platform.id]
  }

  tags                = local.common_tags

}

resource "azurerm_menitor_diagnostic_setting" "appgw" {
  name                       ="appgw-diagnostics"
  target_resource_id         = azurerm_application_gateway.platform.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id


  enabled_log {
    category   = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category   = "ApplicationGatewayFirewallLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  mertic {
    category = "AllMetrics"
    enabled  = true
  }
}