output "state_bucket" {
  value = google_storage_bucket.state.name
}
output "artifact_registry" {
  value = local.repo_url
}
output "build_service_account" {
  value = google_service_account.build.email
}
output "app_triggers" {
  value = { pr = google_cloudbuild_trigger.pr.name, main = google_cloudbuild_trigger.main.name }
}
