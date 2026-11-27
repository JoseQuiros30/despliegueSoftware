module "security" {
  source                = "./modules/security"
  project_id            = var.project_id
  prefix                = var.prefix
  build_service_account = var.build_service_account
}

module "database" {
  source      = "./modules/database"
  prefix      = var.prefix
  region      = var.region
  tier        = var.db_tier
  db_password = module.security.db_password
}

module "storage" {
  source     = "./modules/storage"
  project_id = var.project_id
  prefix     = var.prefix
  region     = var.region
  runtime_sa = module.security.runtime_sa
}

module "cloudrun" {
  source          = "./modules/cloudrun"
  project_id      = var.project_id
  prefix          = var.prefix
  region          = var.region
  image           = var.initial_image
  connection_name = module.database.connection_name
  db_name         = module.database.db_name
  db_user         = module.database.db_user
  runtime_sa      = module.security.runtime_sa
  secret_ids      = module.security.secret_ids
  uploads_bucket  = module.storage.bucket_name
  depends_on      = [module.security, module.storage]
}

module "monitoring" {
  source       = "./modules/monitoring"
  project_id   = var.project_id
  prefix       = var.prefix
  region       = var.region
  service_name = module.cloudrun.service_name
  service_url  = module.cloudrun.service_url
  sql_id       = "${var.project_id}:${module.database.instance_name}"
  alert_emails = var.alert_emails
}
