### 1 - network - VPC ###
resource "google_compute_network"  "terraform_vpc_1" {
  name                    = "${var.name}-vpc-1"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "terraform_sub_vpc_1" {
  name                     = "${var.name}-sub-vpc-1"
  ip_cidr_range            = var.ipv4_private_adress_range
  network                  = google_compute_network.terraform_vpc_1.id
  private_ip_google_access = true
}
### 1 - network - VPC ###

### 2 - network - NAT and router ###
resource "google_compute_router" "terraform_router_1" {
  name    = "${var.name}-router-1"
  network = google_compute_network.terraform_vpc_1.id
  bgp {
    asn   = 64514
  }
}

resource "google_compute_router_nat" "terraform_nat_1" {
  depends_on                         = [google_project_service.api_7_iam]
  
  name                               = "${var.name}-nat-1"
  router                             = google_compute_router.terraform_router_1.name
  region                             = google_compute_router.terraform_router_1.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable                           = var.is_router_logs_enabled
    filter                           = "ERRORS_ONLY"
  }
}
### 2 - network - NAT and router ###

### 2+ - network - firewall that allows connection from VM private ip ###
resource "google_compute_firewall" "allow_ssh_http_for_vm" {
  name          = "${var.name}-allow-ssh-and-http-to-vm"
  network       = google_compute_network.terraform_vpc_1.name
  priority      = 1000
  allow {
    protocol    = "icmp"
  }
  allow {
    protocol    = "tcp"
    ports       = ["22", "80", "8080"]
  }
  source_tags   = ["web", "http-server"]
  source_ranges = [var.ip_cidr_range]
}
### 2+ - network - firewall that allows connection from VM private ip ###