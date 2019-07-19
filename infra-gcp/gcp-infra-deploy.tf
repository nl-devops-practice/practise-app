provider "google" {
  credentials = "${file("My First Project-42d1589a76bb.json")}"
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# To avoid initial errors make sure API permissions are already enabled in the project
# and the service account has Owner-level permissions

# Create VPC and Subnets 
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = true
  project = var.project_id
}

# Create App Engine
resource "google_app_engine_application" "app" {
  depends_on = [google_compute_network.vpc_network]
  project = var.project_id
  location_id = var.location
}

resource "google_app_engine_firewall_rule" "rule" {
  depends_on = [google_compute_network.vpc_network]
  project = google_app_engine_application.app.project
  priority = 1000
  action = "ALLOW"
  source_range = "*"
}

# Create new DB with user credentials and restricted access only to google account and app
resource "google_sql_database_instance" "postgres" {
  depends_on = [google_app_engine_application.app]
  name = var.server_name
  database_version = "POSTGRES_11"
  region = var.region
  project = var.project_id

  settings {
    tier = "db-f1-micro"

    authorized_gae_applications = [
      "${google_app_engine_application.app.id}"
    ]
  }
}

resource "google_sql_user" "master" {
  depends_on = [google_sql_database_instance.postgres]
  name     = var.admin_name
  instance = "${google_sql_database_instance.postgres.name}"
  password = var.admin_pass
  project = var.project_id
}