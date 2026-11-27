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
variable "github_owner" {
  type = string
}
variable "github_connection" {
  type    = string
  default = "github"
}
variable "app_repo_name" {
  type    = string
  default = "despliegueSoftware"
}
variable "main_branch" {
  type    = string
  default = "main"
}
