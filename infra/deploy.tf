provider "azurerm" {
  version = "=1.28.0"
}
# Create a resource group
  resource "azurerm_resource_group" "devops-test"{
  name     = var.resource_group_name
  location = var.location
}

# Create load balancing app service plan
resource "azurerm_app_service_plan" "devops-test" {
  depends_on          = [azurerm_resource_group.devops-test]
  name                = var.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  reserved            = "true"

  sku {
    tier = "Standard"
    size = "S1"
    capacity = 2
  }
}

# Create initial web app
resource "azurerm_app_service" "devops-test" {
  depends_on          = [azurerm_app_service_plan.devops-test]
  name                = var.web_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = "${azurerm_app_service_plan.devops-test.id}"
  https_only          = "true"

  site_config {
    python_version  = 3.4
  }
}

# Create PostgreSQL server and setup admin credentials
resource "azurerm_postgresql_server" "devops-test" {
  depends_on          = [azurerm_resource_group.devops-test]
  name                =  var.server_name
  location            =  var.location
  resource_group_name =  var.resource_group_name

  sku {
    name     = "B_Gen5_2"
    capacity = 2
    tier     = "Basic"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = var.admin_name
  administrator_login_password = var.admin_pass
  version                      = "9.5"
  ssl_enforcement              = "Enabled"
}

# Configure a firewall rule for the server
resource "azurerm_postgresql_firewall_rule" "test" {
  depends_on          = [azurerm_postgresql_server.devops-test]
  name                = "allow-all-azure-ip"
  resource_group_name = var.resource_group_name
  server_name         = var.server_name
  start_ip_address    = var.start_ip
  end_ip_address      = var.end_ip
}

