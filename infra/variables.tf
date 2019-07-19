# Secret Credentials //  Use Terraform.tfvars File
variable "subscription_id" {
  type = "string"
  default = "x"
}
variable "client_id" {
  type = "string"
  default = "x"
}
variable "client_secret" {
  type = "string"
  default = "x"
}
variable "tenant_id" {
  type = "string"
  default = "x"
}

# Standard Variables:
variable "resource_group_name" {
  type = "string"
  default = "Flask-resourcegroup-epam-name-test"
}
variable "location" {
  type = "string"
  default = "centralus"
}
variable "plan_name" {
  type = "string"
  default = "Flask-EPAM-Test-App-Test-plan"
}
variable "web_name" {
  type = "string"
  default = "Flask-EPAM-Test-App-Test"
}
variable "server_name" {
  type = "string"
  default = "server-20075"
}
variable "admin_name" {
  type = "string"
  default = "Sqladmin"
}
variable "admin_pass" {
  type = "string"
  default = "ChangeYourAdminPassword1"
}
variable "start_ip" {
  type = "string"
  default = "0.0.0.0"
}
variable "end_ip" {
  type = "string"
  default = "0.0.0.0"
}

# Output Variables
output "database_endpoint" {
  value = "${var.server_name}.postgres.database.azure.com"
}
output "appservice_endpoint" {
  value = "${var.web_name}.azurewebsites.net"
}