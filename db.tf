### 4+ - vpc connection and private ip for db ### 
resource "google_compute_global_address" "private_ip_address" {
  depends_on    = [google_project_service.api_2_cloudsql_admin]
  name          = "${var.name}-db-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.terraform_vpc_1.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  depends_on              = [google_project_service.api_2_cloudsql_admin]
  network                 = google_compute_network.terraform_vpc_1.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 3
}
### 4+ - vpc connection and private ip for db ### 

### 4 - cloud SQL with only private IP ###
resource "google_sql_database_instance" "terraform_sql_private_instance" {
  name                = "${var.name}-private-instance-${random_id.db_name_suffix.hex}"
  region              = var.region
  database_version    = var.sql_database_version
  depends_on          = [google_service_networking_connection.private_vpc_connection]
  deletion_protection = false
  
  settings {
    tier              = var.sql_database_vm_tier
    disk_size         = 10
    ip_configuration {
      require_ssl     = false
      ipv4_enabled    = false
      private_network = google_compute_network.terraform_vpc_1.id
    }
  }
}

resource "google_sql_database" "database" {
  name       = var.sql_php_app_database_name
  instance   = google_sql_database_instance.terraform_sql_private_instance.name
}

resource "google_sql_user" "db_user_1" {
  name     = var.sql_user_1_name
  instance = google_sql_database_instance.terraform_sql_private_instance.name
  password = var.sql_user_1_password
}
### 4 - cloud SQL with only private IP ###