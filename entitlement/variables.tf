variable "environment" {
  type = string
}

variable "entitlement_name" {
  type        = string
  description = "Name of the entitlement. This is likely the name of an existing Okta group."
}

variable "conductorone_directory_app_id" {
  type        = string
  description = "App ID assigned to Okta."
}

variable "maximum_duration_grant" {
  type        = string
  description = "Maximum duration grant in seconds."
  default     = "604800s"
}

variable "risk_level" {
  type        = string
  description = "Risk level assigned to the entitlement."
}

variable "slug" {
  type        = string
  description = "Append at end of entitlement."
  default     = "member"
}

variable "entitlement_description" {
  type = string
}

variable "entitlement_source" {
  type        = string
  description = "Is entitlement source defined by an (okta) group or a (native) integration?"
  default     = "okta"

  validation {
    condition     = contains(["okta", "native"], var.entitlement_source)
    error_message = "Must be either \"okta\" or \"native\"."
  }
}

variable "catalogs" {
  type        = list(string)
  description = "List of catalog names that an entitlement should belong to."
  default     = []
}

variable "request_policy" {
  type        = string
  description = "Request/Grant Policy (display name)"
}

variable "review_policy" {
  type        = string
  description = "Review/Certification Policy (display name)"
}

variable "revoke_policy" {
  type        = string
  description = "Revoke/Removal Policy (display name)"
}

variable "emergency_grant_enabled" {
  type        = bool
  description = "Emergency Policy enabled (T/F)"
}

variable "emergency_grant_policy_name" {
  type        = string
  description = "Emergency Policy Name"
  default     = ""
}

variable "trigger" {
  type        = string
  description = "This is an md5 hash used to trigger Terraform when changes are made to YAML files."
}
