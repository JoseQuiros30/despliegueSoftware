output "service_url" {
  value = module.cloudrun.service_url
}
output "service_name" {
  value = module.cloudrun.service_name
}
output "db_instance_name" {
  value = module.database.instance_name
}
output "db_connection_name" {
  value = module.database.connection_name
}
output "dashboard_url" {
  value = module.monitoring.dashboard_url
}
output "uploads_bucket" {
  value = module.storage.bucket_name
}
