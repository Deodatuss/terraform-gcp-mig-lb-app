### 7 - template and MIG ###
resource "google_compute_instance_template" "default" {
  depends_on = [google_project_service.api_7_iam]
  
  name  = "${var.name}-php-app-template"

  instance_description = "instance template with startup script"
  machine_type         = var.instance_template_machine_type
  can_ip_forward       = false
  tags = ["http-server", "https-server"]

  disk {
    source_image      = var.instance_template_source_image
    auto_delete       = true
    boot              = true
  }
  network_interface {
    //network = google_compute_network.terr_vpc_1.id
    subnetwork = google_compute_subnetwork.terraform_sub_vpc_1.id
    access_config {
    network_tier = "STANDARD"
    }
    # Gives Google error because is trying to constantly update non-updatable template
    # ipv6_access_config {
    #   network_tier = "STANDARD"
    # }
  }
  service_account {
  email = google_service_account.custom_service_account_1.email
  scopes = ["cloud-platform"]
  }
  metadata_startup_script = templatefile(var.instance_template_startup_shell_script,
    {
        sql_server_ip     = google_sql_database_instance.terr_sql_private_instance.private_ip_address
        sql_user_name     = var.sql_database_user_1_name
        sql_user_password = var.sql_database_user_1_password
        sql_db_name       = var.sql_php_app_database_name
        sql_path_to_cript = var.instance_template_sql_script_for_db

    })
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "appserver" {
  depends_on = [google_project_service.api_7_iam]
  
  name                = "${var.name}-terraform-custom-mig"
  base_instance_name  = "${var.name}-php-app-worker"
  zone                = var.zone
  version {
    instance_template = google_compute_instance_template.default.id
  }

  target_size         = 2

  named_port {
    name              = "default-http"
    port              = 80
  }
  named_port {
    name              = "http"
    port              = 80
  }
  named_port {
    name              = "default-ssh"
    port              = 22
  }
  named_port {
    name              = "ssh"
    port              = 22
  }
}
### 7 - template and MIG ###

### 8 - external HTTP load balancer with the MIG backend ###
resource "google_compute_subnetwork" "terraform_proxy_vpc_1" {
  name          = "${var.name}-proxy-vpc-1"
  ip_cidr_range = var.ip_proxy_range
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.terraform_vpc_1.id
}

resource "google_compute_region_health_check" "default" {
  name     = "${var.name}-mig-healhckeck"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

resource "google_compute_region_backend_service" "default" {
  name                  = "${var.name}-backend-external-subnet"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.default.id]
  backend {
    group               = google_compute_instance_group_manager.appserver.instance_group
    balancing_mode      = "UTILIZATION"
    capacity_scaler     = 1.0
  }
}

resource "google_compute_region_url_map" "default" {
  name            = "${var.name}-regional-url-map"
  default_service = google_compute_region_backend_service.default.id
}

resource "google_compute_region_target_http_proxy" "default" {
  name     = "${var.name}-target-http-proxy"
  url_map  = google_compute_region_url_map.default.id
}

resource "google_compute_address" "default" {
  name         = "${var.name}-website-public-ip-1"
  network_tier = "STANDARD"
}

resource "google_compute_forwarding_rule" "terraform_lb_forward_rule" {
  name                  = "${var.name}-forwarding-rule"
  depends_on            = [google_compute_subnetwork.terr_proxy_vpc_1]
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.terraform_vpc_1.id
  # if somrthing with lb doesn't work, it could be answer (but a last one, because it worked without subnet)
  # subnetwork            = google_compute_subnetwork.terraform_sub_vpc_1.id
  ip_address            = google_compute_address.default.id

  network_tier          = "STANDARD"
}
### 8 - external HTTP load balancer with the MIG backend ###

### 8+ - load balancer firewall ###
## allow all access from IAP and health check ranges ##
resource "google_compute_firewall" "fw-iap" {
  name          = "${var.name}-fw-allow-iap-hc"
  direction     = "INGRESS"
  network       = google_compute_network.terraform_vpc_1.id
  source_ranges = var.firewall_allow_external_ranges
  allow {
    protocol    = "tcp"
  }
}

## allow http from proxy subnet to backends ##
resource "google_compute_firewall" "fw-ilb-to-backends" {
  name          = "${var.name}-fw-allow-ilb-to-backends"
  direction     = "INGRESS"
  network       = google_compute_network.terraform_vpc_1.id
  source_ranges = ["${var.ip_cidr_range}"]
  target_tags   = ["http-server"]
  allow {
    protocol    = "tcp"
    ports       = ["80", "443", "8080"]
  }
}
### 8+ - load balancer firewall ###