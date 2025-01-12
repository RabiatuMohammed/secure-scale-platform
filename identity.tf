resource "azurerm_user_assigned_identity" "platform" {
  name                = "id-${var.environment}-platform"
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  tags                = local.common_tags
}

resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "id-${var.environment}-aks"
  resource_group_name =  azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  tags                = local.common_tags
}