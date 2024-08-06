variable "environment" {
  type = string
}

variable "catalog_display_name" {
  type        = string
  description = "Name of the catalog."
}

variable "catalog_description" {
  type        = string
  description = "Description of the catalog to be delegated."
}

// App owner email is required to pull C1 data source / app owner ID
variable "catalog_visible_to_everyone" {
  type        = bool
  description = "Catalog is visible to all users. (T/F)"
}

variable "catalog_active" {
  type        = bool
  description = "Catalog is published and active. (T/F)"
}

variable "catalog_users" {
  type        = list(string)
  description = "List of Okta Groups who may access this catalog"
  default     = []
}

variable "conductorone_directory_app_id" {
  type        = string
  description = "App ID assigned to Okta"
}

variable "breakglass_group_name" {
  type        = string
  description = "Name of Okta group dedicated to full breakglass/emergency."
}

variable "trigger" {
  type        = string
  description = "This is an md5 hash used to trigger Terraform when changes are made to YAML files."
}
