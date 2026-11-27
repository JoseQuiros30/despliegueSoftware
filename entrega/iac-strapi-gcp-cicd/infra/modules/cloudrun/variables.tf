variable "project_id" {
  type = string
}
variable "prefix" {
  type = string
}
variable "region" {
  type = string
}
variable "image" {
  type = string
}
variable "connection_name" {
  type = string
}
variable "db_name" {
  type = string
}
variable "db_user" {
  type = string
}
variable "runtime_sa" {
  type = string
}
variable "secret_ids" {
  type = map(string)
}
variable "uploads_bucket" {
  type = string
}
