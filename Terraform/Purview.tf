# azurerm_purview_account
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/purview_account

resource "azurerm_purview_account" "purview-act" {
  name                = "${var.environment}${var.application}${var.iteration}act"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.default_tags

  identity {
    type = "SystemAssigned"
  }
}
