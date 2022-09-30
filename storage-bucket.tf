### 6 - Storage Bucket with PHP application ###
resource "google_storage_bucket" "terraform_custom_bucket" {
  # dependency on sql instance is stated, because server's private ip is needed for db.php conn file   
  depends_on = [google_sql_database_instance.terraform_sql_private_instance]
  
  name          = "${var.name}-php-application-bucket"
  storage_class = "REGIONAL"
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
}
### 6 - Storage Bucket with PHP application ###

### 6+ - Files to load into Storage Bucket ###
variable "files" {
  depends_on = [google_storage_bucket.terraform_custom_bucket]
  type = map(string)
  default = {
    # sourcefile = destfile
    # "php-mysql-crud-master/db.php" -- this file is added with another resource as a string, 
    # because it has terraform vars and need to be modulable 
    "delete_task.php"  = "php-mysql-crud-master/delete_task.php"
    "edit.php" = "php-mysql-crud-master/edit.php"
    "index.php" = "php-mysql-crud-master/index.php"
    "Instrucciones" = "php-mysql-crud-master/Instrucciones"
    "README.md" = "php-mysql-crud-master/README.md"
    "save_task.php" = "php-mysql-crud-master/save_task.php"
    # folder database/
    "database/script.sql" = "php-mysql-crud-master/database/script.sql"
    # folder docs/
    "docs/screenshot.png" = "php-mysql-crud-master/docs/screenshot.png"
    # folder includes/
    "includes/footer.php" = "php-mysql-crud-master/includes/footer.php"
    "includes/header.php" = "php-mysql-crud-master/includes/header.php"
  }
}

resource "google_storage_bucket_object" "php_app_push_most_objects" {
  depends_on = [google_storage_bucket.terraform_custom_bucket]
  
  for_each = var.files
  name     = each.value
  source   = join("", [var.bucket_path_to_files_directory, each.key])
  bucket   = google_storage_bucket.terraform_custom_bucket.name
}

resource "google_storage_bucket_object" "php_app_push_db_conn_file" {
  depends_on = [google_storage_bucket.terraform_custom_bucket]
  
  name     = "php-mysql-crud-master/db.php"
  content   = templatefile(join("", [var.bucket_path_to_files_directory, "db.php"]),
    {
        sql_server_ip = google_sql_database_instance.terraform_sql_private_instance.private_ip_address
    })
  bucket   = google_storage_bucket.terraform_custom_bucket.name
}
### 6+ - Files to load into Storage Bucket ###