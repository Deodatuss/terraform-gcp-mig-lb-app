resource "google_project_service" "api_0_resource_manager" {
  service = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = true
}
resource "google_project_service" "api_1_compute_engine" {
  service = "compute.googleapis.com"
  disable_dependent_services = true
  depends_on = [google_project_service.api_0_resource_manager]
} 
resource "google_project_service" "api_2_cloudsql_admin" {
  service = "sqladmin.googleapis.com"
  disable_dependent_services = true
  depends_on = [google_project_service.api_1_compute_engine]
} 
resource "google_project_service" "api_3_network_management" {
  service = "networkmanagement.googleapis.com"
  disable_dependent_services = true
  depends_on = [google_project_service.api_2_cloudsql_admin]
} 
resource "google_project_service" "api_4_service_networking" {
  service = "servicenetworking.googleapis.com"
  disable_dependent_services = true
  depends_on = [google_project_service.api_3_network_management]
} 
resource "google_project_service" "api_5_cloud_os_login" {
  service = "oslogin.googleapis.com"
  disable_dependent_services = true
  depends_on = [google_project_service.api_4_service_networking]
}
resource "google_project_service" "api_6_iam" {
  service = "iam.googleapis.com"
  disable_dependent_services = true
  depends_on = [google_project_service.api_5_cloud_os_login]
}