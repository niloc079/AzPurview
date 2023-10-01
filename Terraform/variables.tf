#
#Tags
variable "environment" {
  type = string
}

variable "application" {
  type = string
}

variable "location" {
  type = string
}

variable "iteration" {
  type = string
}

variable "application_owner" {
  type = string
}

variable "deployment_source" {
  type = string
}

variable "default_tags" {
  type = map
}

#Custom
variable "sqllogin" {
  type = string
  description = "administrator_login"
}

variable "sqlpass" {
  type = string
  description = " administrator_login_password"
}

variable "sqladminlogin" {
  type = string
  description = "azuread_administrator login_username"
}

variable "sqladminloginid" {
  type = string
  description = "azuread_administrator object_id"
}
