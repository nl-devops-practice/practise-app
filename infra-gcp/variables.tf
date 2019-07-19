# Standard Variables:
variable "project_id" {
    type = "string"
    default = "rich-analog-246513"
}
variable "region" {
  type = "string"
  default = "europe-west1"
}
variable "zone" {
  type = "string"
  default = "europe-west1-b"
}

# GCP variables

variable "location" {
  type = "string"
  default = "europe-west"
}

variable "server_name" {
  type = "string"
  default = "masterserver-2007501201391492"
}
variable "admin_name" {
  type = "string"
  default = "Sqladmin"
}
variable "admin_pass" {
  type = "string"
  default = "ChangeYourAdminPassword1"
}

# Output Variables
output "db_endpoint" {
  value = [google_sql_database_instance.postgres.connection_name]
}