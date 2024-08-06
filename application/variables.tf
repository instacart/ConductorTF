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

// App owner email is required to pull C1 data source / app owner ID
variable "app_owner_email" {
  type        = string
  description = "App Owner's full e-mail address. This may be used in downstream approval workflows."
}

variable "trigger" {
  type        = string
  description = "This is an md5 hash used to trigger Terraform when changes are made to YAML files."
}
