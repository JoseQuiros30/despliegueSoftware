resource "random_id" "suffix" { byte_length = 3 }

resource "google_sql_database_instance" "main" {
  name                = "${var.prefix}-pg-${random_id.suffix.hex}"
  database_version    = "POSTGRES_16"
  region              = var.region
  deletion_protection = false
  settings {
    tier              = var.tier
    edition           = "ENTERPRISE"
    availability_type = "ZONAL"
    disk_type         = "PD_HDD"
    disk_size         = 10
    disk_autoresize   = false
    ip_configuration { ipv4_enabled = true }
    backup_configuration { enabled = false }
    user_labels = { application = var.prefix }
  }
}

resource "google_sql_database" "app" {
  name     = "strapi"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app" {
  name     = "strapi"
  instance = google_sql_database_instance.main.name
  password = var.db_password
}
