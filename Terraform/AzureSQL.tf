#
resource "azurerm_mssql_server" "AzureSQL-sql-srv" {
  name                         = "${var.environment}${var.application}${var.iteration}-sql-srv"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = var.location
  version                      = "12.0"
  minimum_tls_version          = "1.2"
  administrator_login          = var.sqllogin
  administrator_login_password = var.sqlpass
  tags                         = var.default_tags

  azuread_administrator {
    login_username  = data.azurerm_client_config.current.client_id
    object_id       = data.azurerm_client_config.current.object_id
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_database" "AzureSQL-sql-db0" {
  name                  = "${var.environment}${var.application}${var.iteration}-sql-db0"
  server_id             = azurerm_mssql_server.AzureSQL-sql-srv.id
  collation             = "SQL_Latin1_General_CP1_CI_AS"
  license_type          = "LicenseIncluded"
  max_size_gb           = 2
  #read_scale            = true
  sku_name              = "Basic"
  zone_redundant        = false
  geo_backup_enabled    = false
  sample_name           = "AdventureWorksLT"
  tags                  = var.default_tags
}
