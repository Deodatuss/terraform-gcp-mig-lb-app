### 3 - service account ###
resource "google_service_account" "custom_service_account_1" {
  depends_on = [google_project_service.api_6_iam]

  account_id   = "${var.name}-service-account-1"
  display_name = "${var.name}-service-acc-for-connections"
  description = "Custom terraform-issued service account for ${var.name}"
}
### 3 - service account ###

### 3+ - roles for service account ###
resource "google_project_iam_member" "service_account_1_IAv1" {
  depends_on = [google_service_account.custom_service_account_1]
  
  project    = var.gcp_project
  role       = "roles/compute.instanceAdmin.v1"
  member     = "serviceAccount:${google_service_account.custom_service_account_1.email}"
}

resource "google_project_iam_member" "service_account_1_OA" {
  depends_on = [google_service_account.custom_service_account_1]
  
  project    = var.gcp_project
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.custom_service_account_1.email}"
}

resource "google_project_iam_member" "service_account_1_NA" {
  depends_on = [google_service_account.custom_service_account_1]
  
  project    = var.gcp_project
  role       = "roles/compute.networkAdmin"
  member     = "serviceAccount:${google_service_account.custom_service_account_1.email}"
}

resource "google_project_iam_member" "service_account_1_IAP" {
  depends_on = [google_service_account.custom_service_account_1]
  
  project    = var.gcp_project
  role       = "roles/iap.tunnelResourceAccessor"
  member     = "serviceAccount:${google_service_account.custom_service_account_1.email}"
}

resource "google_project_iam_member" "service_account_1_SA" {
  depends_on = [google_service_account.custom_service_account_1]
  
  project    = var.gcp_project
  role       = "roles/storage.admin"
  member     = "serviceAccount:${google_service_account.custom_service_account_1.email}"
}
### 3+ - roles for service account ###