output "runtime_sa" {
  value = google_service_account.run.email
}
output "db_password" {
  value     = random_password.secrets["db-password"].result
  sensitive = true
}
output "secret_ids" {
  value = { for k, v in google_secret_manager_secret.app : k => v.secret_id }
}
