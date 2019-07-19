provider "azurerm" {
  version = "=1.28.0"
}

# Add backend
#terraform {
#  backend "azurerm" {
#    storage_account_name = "terraformteststoragefore"
#    container_name       = "production-tf"
#    key                  = "prod.terraform.tfstate"
#  }
#}

# Create a resource group
  resource "azurerm_resource_group" "devops-test" {
  name     = var.resource_group_name
  location = var.location
}

# Create Kubernetes Cluster
resource "azurerm_kubernetes_cluster" "devops-test" {
  depends_on          = [azurerm_resource_group.devops-test]
  name                = var.kluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "flaskagent1"

  agent_pool_profile {
    name            = "flask"
    count           = 1
    vm_size         = "Standard_B2s"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
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

