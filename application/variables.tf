variable "environment" {
  type = string
}

variable "app_display_name" {
  type        = string
  description = "Name of the application."
}

variable "app_description" {
  type        = string
  description = "Description of the application to be delegated."
}

variable "app_owner_email" {
  type        = string
  description = "App Owner's full e-mail address. This may be used in downstream approval workflows."
}

variable "mirrored_app" {
  type        = bool
  description = "Is this a mirrored application strictly for UI purposes. (T/F)"
  default     = false
}

variable "resource_type_name" {
  type        = string
  description = "Display name for the entitlement resource type on mirrored apps."
  default     = "group"
}

variable "trigger" {
  type        = string
  description = "An MD5 hash used to trigger Terraform when changes are made to external data files."
}
