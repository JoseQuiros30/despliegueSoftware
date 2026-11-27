resource "google_cloud_run_v2_service" "app" {
  name                = "${var.prefix}-service"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    service_account                  = var.runtime_sa
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN2"
    max_instance_request_concurrency = 10
    timeout                          = "300s"
    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }
    volumes {
      name = "cloudsql"
      cloud_sql_instance { instances = [var.connection_name] }
    }
    volumes {
      name = "uploads"
      gcs {
        bucket        = var.uploads_bucket
        read_only     = false
        mount_options = ["uid=1000", "gid=1000"]
      }
    }
    containers {
      name  = "strapi"
      image = var.image
      ports { container_port = 1337 }
      resources {
        limits   = { cpu = "1", memory = "2Gi" }
        cpu_idle = true
      }
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
      volume_mounts {
        name       = "uploads"
        mount_path = "/opt/app/public/uploads"
      }
      env {
        name  = "NODE_ENV"
        value = "production"
      }
      env {
        name  = "IS_PROXIED"
        value = "true"
      }
      env {
        name  = "DATABASE_CLIENT"
        value = "postgres"
      }
      env {
        name  = "DATABASE_HOST"
        value = "/cloudsql/${var.connection_name}"
      }
      env {
        name  = "DATABASE_NAME"
        value = var.db_name
      }
      env {
        name  = "DATABASE_USERNAME"
        value = var.db_user
      }
      env {
        name  = "DATABASE_POOL_MAX"
        value = "4"
      }
      dynamic "env" {
        for_each = {
          DATABASE_PASSWORD   = "db-password"
          APP_KEYS            = "app-keys"
          API_TOKEN_SALT      = "api-token-salt"
          ADMIN_JWT_SECRET    = "admin-jwt-secret"
          TRANSFER_TOKEN_SALT = "transfer-token-salt"
          JWT_SECRET          = "jwt-secret"
          ENCRYPTION_KEY      = "encryption-key"
        }
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = var.secret_ids[env.value]
              version = "latest"
            }
          }
        }
      }
      startup_probe {
        initial_delay_seconds = 10
        period_seconds        = 10
        timeout_seconds       = 5
        failure_threshold     = 24
        tcp_socket { port = 1337 }
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].containers[0].image, traffic]
  }
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.project_id
  location = google_cloud_run_v2_service.app.location
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
