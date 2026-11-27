resource "google_storage_bucket" "uploads" {
  name                        = "${var.project_id}-${var.prefix}-uploads"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false
}

resource "google_storage_bucket_iam_member" "runtime" {
  bucket = google_storage_bucket.uploads.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${var.runtime_sa}"
}
