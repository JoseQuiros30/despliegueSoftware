locals {
  repo_url = "${var.region}-docker.pkg.dev/${var.project_id}/${var.prefix}"
  service  = "${var.prefix}-service"
}

resource "google_project_service" "apis" {
  for_each = toset([
    "artifactregistry.googleapis.com", "cloudbuild.googleapis.com", "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com", "logging.googleapis.com", "monitoring.googleapis.com",
    "run.googleapis.com", "secretmanager.googleapis.com", "serviceusage.googleapis.com",
    "sqladmin.googleapis.com", "storage.googleapis.com"
  ])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_storage_bucket" "state" {
  name                        = "${var.project_id}-${var.prefix}-tfstate"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false
  versioning { enabled = true }
  lifecycle_rule {
    condition { num_newer_versions = 20 }
    action { type = "Delete" }
  }
  depends_on = [google_project_service.apis]
}

resource "google_artifact_registry_repository" "app" {
  location      = var.region
  repository_id = var.prefix
  format        = "DOCKER"
  description   = "Imágenes de Strapi Actividad 5"
  depends_on    = [google_project_service.apis]
}

resource "google_service_account" "build" {
  account_id   = "${var.prefix}-build"
  display_name = "Cloud Build demo-strapi"
  depends_on   = [google_project_service.apis]
}

resource "google_project_iam_member" "build" {
  for_each = toset(["roles/run.developer", "roles/logging.logWriter", "roles/storage.objectViewer"])
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.build.email}"
}

resource "google_artifact_registry_repository_iam_member" "writer" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.app.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.build.email}"
}

resource "google_cloudbuildv2_repository" "app" {
  name              = var.app_repo_name
  location          = var.region
  parent_connection = "projects/${var.project_id}/locations/${var.region}/connections/${var.github_connection}"
  remote_uri        = "https://github.com/${var.github_owner}/${var.app_repo_name}.git"
  depends_on        = [google_project_service.apis]
}

resource "google_cloudbuild_trigger" "pr" {
  name            = "${var.prefix}-app-pr"
  location        = var.region
  filename        = "entrega/demo-strapi/cloudbuild.yaml"
  included_files  = ["entrega/demo-strapi/**", ".gcloudignore"]
  service_account = google_service_account.build.id
  substitutions = {
    _REGION = var.region, _AR_REPO = local.repo_url, _SERVICE = local.service, _DEPLOY = "false"
  }
  repository_event_config {
    repository = google_cloudbuildv2_repository.app.id
    pull_request {
      branch          = "^${var.main_branch}$"
      comment_control = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
    }
  }
  depends_on = [google_project_iam_member.build, google_artifact_registry_repository_iam_member.writer]
}

resource "google_cloudbuild_trigger" "main" {
  name            = "${var.prefix}-app-main"
  location        = var.region
  filename        = "entrega/demo-strapi/cloudbuild.yaml"
  included_files  = ["entrega/demo-strapi/**", ".gcloudignore"]
  service_account = google_service_account.build.id
  substitutions = {
    _REGION = var.region, _AR_REPO = local.repo_url, _SERVICE = local.service, _DEPLOY = "true"
  }
  repository_event_config {
    repository = google_cloudbuildv2_repository.app.id
    push { branch = "^${var.main_branch}$" }
  }
  depends_on = [google_project_iam_member.build, google_artifact_registry_repository_iam_member.writer]
}
