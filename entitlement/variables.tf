variable "environment" {
  type = string
}

variable "entitlement_name" {
  type        = string
  description = "Name of the entitlement. This is likely the name of an existing IdP group."
}

variable "entitlement_alternate_name" {
  type        = string
  description = "Alternate display name for the entitlement. Useful when mirroring an application under a different name."
  default     = "None"
}

variable "conductorone_directory_app_id" {
  type        = string
  description = "App ID assigned to your identity provider (e.g. Okta) in ConductorOne."
}

variable "target_app_id" {
  type        = string
  description = "App ID assigned to target application. Required when entitlement_source is 'native'."
  default     = ""
}

variable "mirrored_application_name" {
  type        = string
  description = "When entitlement is tied to a mirrored application, the display name of the mirrored app in ConductorOne."
  default     = "Okta"
}

variable "mirrored_application_resource_type_id" {
  type        = string
  description = "Resource Type ID for GROUP entitlements in the mirrored application."
  default     = "2e40qJR3fvmcnnv5hC85lrGpIWq"
}

variable "mirrored_app" {
  type        = bool
  description = "Is this a mirrored application strictly for UI purposes. (T/F)"
  default     = true
}

variable "maximum_duration_grant" {
  type        = string
  description = "Maximum duration grant in seconds. Use '0s' for indefinite access."
  default     = "604800s"
}

variable "risk_level" {
  type        = string
  description = "Risk level value ID assigned to the entitlement."
}

variable "slug" {
  type        = string
  description = "Slug appended to the entitlement identifier."
  default     = "member"
}

variable "entitlement_description" {
  type = string
}

variable "entitlement_source" {
  type        = string
  description = "Source of entitlement: 'okta' for IdP group membership, 'native' for direct app integrations."
  default     = "okta"

  validation {
    condition     = contains(["okta", "native"], var.entitlement_source)
    error_message = "Must be either \"okta\" or \"native\"."
  }
}

variable "access_profiles" {
  type        = list(string)
  description = "List of access profile names that this entitlement should belong to."
  default     = []
}

variable "request_policy" {
  type        = string
  description = "Request/Grant Policy display name."
}

variable "review_policy" {
  type        = string
  description = "Review/Certification Policy display name."
}

variable "revoke_policy" {
  type        = string
  description = "Revoke/Removal Policy display name."
}

variable "emergency_grant_enabled" {
  type        = bool
  description = "Enable emergency policy override for this entitlement. (T/F)"
}

variable "additional_entitlement_required" {
  type        = bool
  description = "Whether an additional group/entitlement needs to be provisioned alongside this one. Creates a linked multi-step provision."
  default     = false
}

variable "additional_entitlement_name" {
  type        = string
  description = "Name of the additional entitlement to provision (required when additional_entitlement_required is true)."
  default     = "None"
}

variable "additional_entitlement_skip_revoke" {
  type        = bool
  description = "Whether to skip revocation of the additional entitlement. Useful for app-level access that should persist independently."
  default     = false
}

variable "emergency_grant_policy_name" {
  type        = string
  description = "Display name of the emergency grant policy."
  default     = ""
}

variable "trigger" {
  type        = string
  description = "An MD5 hash used to trigger Terraform when changes are made to external data files."
}

variable "webhook_provision" {
  default     = false
  type        = bool
  description = "Whether this entitlement is provisioned via a custom webhook rather than the connector. (T/F)"
}

variable "multistep_webhook_provision" {
  default     = false
  type        = bool
  description = "Whether this entitlement is provisioned via a webhook followed by a connector step. (T/F)"
}

variable "webhook_provision_id" {
  type        = string
  description = "ID of the webhook used as the provision step for this entitlement."
  default     = "None"
}

variable "conductorone_service_account_email" {
  type        = string
  description = "Email address of the ConductorOne service account used for data lookups."
}

variable "all_entitlements" {
  description = "Map of entitlement display names to their IDs."
}

variable "all_policies" {
  description = "Map of policy display names to their IDs."
}

variable "all_access_profiles" {
  description = "Map of access profile display names to their IDs."
}

variable "all_webhooks" {
  description = "Map of webhook display names to their IDs."
}
