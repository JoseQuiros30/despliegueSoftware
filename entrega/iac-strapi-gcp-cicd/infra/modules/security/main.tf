resource "google_service_account" "run" {
  account_id   = "${var.prefix}-run"
  display_name = "Strapi Cloud Run"
}

resource "google_project_iam_member" "sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.run.email}"
}

resource "google_service_account_iam_member" "build_act_as" {
  service_account_id = google_service_account.run.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.build_service_account}"
}

resource "random_password" "secrets" {
  for_each = toset(["db-password", "app-key-1", "app-key-2", "app-key-3", "app-key-4",
  "api-token-salt", "admin-jwt-secret", "transfer-token-salt", "jwt-secret", "encryption-key"])
  length  = 40
  special = false
}

locals {
  secret_values = {
    db-password         = random_password.secrets["db-password"].result
    app-keys            = join(",", [for n in [1, 2, 3, 4] : random_password.secrets["app-key-${n}"].result])
    api-token-salt      = random_password.secrets["api-token-salt"].result
    admin-jwt-secret    = random_password.secrets["admin-jwt-secret"].result
    transfer-token-salt = random_password.secrets["transfer-token-salt"].result
    jwt-secret          = random_password.secrets["jwt-secret"].result
    encryption-key      = random_password.secrets["encryption-key"].result
  }
  secret_names = toset(keys(local.secret_values))
}

resource "google_secret_manager_secret" "app" {
  for_each  = local.secret_names
  secret_id = "${var.prefix}-${each.key}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "app" {
  for_each    = local.secret_names
  secret      = google_secret_manager_secret.app[each.key].id
  secret_data = local.secret_values[each.key]
}

resource "google_secret_manager_secret_iam_member" "run" {
  for_each  = local.secret_names
  secret_id = google_secret_manager_secret.app[each.key].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.run.email}"
}
