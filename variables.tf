### General ###
variable "cred_file" {
    description = "Name of .json file with connection data for GCP service account"
    type        = string
}

variable "project" {
  description = "The project name to deploy to"
  type        = string
}

variable "region" {
  description = "Project region for regional recources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Project zone, used part of project region"
  type        = string
  default     = "us-central1-c"
}

variable "name" {
  description = "Name and prefix for supporting resources"
  type        = string
}
### General ###

### Addresses ###
variable "ipv4_private_adress_range" {
  description = "CIDR notation private ipv4 adress used for VPC"
  type        = string
  default     = "10.3.0.0/16"  
}

variable "ipv4_private_proxy_range" {
    description = "REGIONAL_MANAGED_PROXY with CIDR notation"
    type        = string
    default     = "10.4.0.0/16"  
}
### Addresses ###

### Networking ###
variable is_router_logs_enabled {
  description = "Determines if gcp collects logs from nat router"
    type      = bool
  default     = true  
}
### Networking ###

### SQL Database ###
variable sql_database_version {
  description = "SQL server name and version that is used for db"
    type      = string
  default     = "MYSQL_8_0"  
}

variable sql_database_vm_tier {
  description = "GCP VM tier that hosts SQL server"
    type      = string
  default     = "db-g1-small" 
}

variable sql_database_disk_size {
  description = "Disk size for database VM"
    type      = number
  default     = 10
}

variable sql_php_app_database_name {
  description = "Database used for storing data"
    type      = string
  default     = "php_mysql_crud" 
}

variable sql_database_user_1_name {
  description = "Database connection user"
    type      = string
  default     = "root" 
}

variable sql_database_user_1_password {
  description = "Database connection password for connection user"
    type      = string
  default     = "password123" 
}
### SQL Database ###

### PHP Application Storage Bucket ###
variable bucket_path_to_files_directory {
  description = "Directory where all php apps and subdirectories are placed"
    type      = string
  default     = "php-mysql-crud-master/" 
}
### PHP Application Storage Bucket ###

### Instance template ###
variable instance_template_machine_type {
  description = "GCP machine size (cpu and ram) used for future instances"
    type      = string
  default     = "e2-small"
}

variable instance_template_source_image {
  description = "Boot disk image with default size equal to 10 gb"
    type      = string
  default     = "ubuntu-2004-lts"
}

variable instance_template_startup_shell_script {
  description = "Path to script that will be started every time on instance start-up"
    type      = string
  default     = "./scripts and templates/first-startup-script.sh"
}

variable instance_template_sql_script_for_db { 
  description = "Same as path in shell cript, INTERNAL path in vm to sql script, which is downloaded from bucket"
    type      = string
  default     = "./scripts and templates/script.sql"
}
### Instance template ###

### Load Balancer ###
variable firewall_allow_external_ranges {
  description = "Allow http from proxy subnet to backends"
    type      = list(string)
  default     = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
}
### Load Balancer ###