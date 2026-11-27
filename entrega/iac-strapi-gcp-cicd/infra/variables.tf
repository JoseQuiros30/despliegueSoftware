variable "project_id" {
  type = string
}
variable "region" {
  type    = string
  default = "us-central1"
}
variable "prefix" {
  type    = string
  default = "strapi-a5"
}
variable "initial_image" {
  type = string
}
variable "build_service_account" {
  type = string
}
variable "db_tier" {
  type    = string
  default = "db-f1-micro"
}
variable "alert_emails" {
  type    = list(string)
  default = []
}
