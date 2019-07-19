
variable "access_key" {
  type = "string"
}
variable "secret_key" {
  type = "string"
}
variable "region" {
  type = "string"
  default = "eu-west-1"
}

# Standard Variables
variable "application_name" {
  type = "string"
  default = "flask-EPAM-Test-App-Test"
}
variable "server_name" {
  type = "string"
  default = "server20075"
}

variable "bucket_name" {
  type = "string"
  default = "flaskbucketforepam"
}

variable "vpc_name" {
  type = "string"
  default = "flask-vpc"
}

variable "port" {
  type = "string"
  default = "5000"
}

variable "admin_name" {
  type = "string"
  default = "Sqladmin"
}

variable "admin_pass" {
  type = "string"
  default = "ChangeYourAdminPassword1"
}

output "db_endoint" {
  value = "${aws_db_instance.postgres.endpoint}"
}