variable "prefix" {
  type = string
}
variable "region" {
  type = string
}
variable "tier" {
  type = string
}
variable "db_password" {
  type      = string
  sensitive = true
}
