output "server_sql_user_1_database" {
    description = "Database with tables to store data from php app."
    value       = google_sql_database.database.name
    # sensitive   = true // can be sensitive
}

output "server_sql_user_1_name" {
    description = "User with access to database."
    value       = google_sql_user.db_user_1.name
    # sensitive   = true // can be sensitive
}

output "server_sql_user_1_password" {
  description = "Database user's password."
  value       = google_sql_user.db_user_1.password
  sensitive   = true // is definitely sensitive
}

output "webserver_load_balancer_external_ip" {
  description = "IPv4 for regular users to connect to."
  value       = google_compute_address.default.address
}