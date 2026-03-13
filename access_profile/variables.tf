variable "environment" {
  type = string
}

variable "access_profile_display_name" {
  type        = string
  description = "Name of the access profile."
}

variable "access_profile_description" {
  type        = string
  description = "Description of the access profile."
}

variable "access_profile_visible_to_everyone" {
  type        = bool
  description = "Access profile is visible to all users. (T/F)"
}

variable "access_profile_active" {
  type        = bool
  description = "Access profile is published and active. (T/F)"
}

variable "target_app_id" {
  type        = string
  description = "App ID assigned to target application. Required when entitlement_source is not 'okta'."
  default     = ""
}

variable "conductorone_self_app_id" {
  type        = string
  description = "The ConductorOne application ID representing the ConductorOne platform itself. Required for bundle enrollment entitlements."
}

variable "access_profile_users" {
  type        = list(string)
  description = "List of groups who may access this access profile. Required when access_profile_visible_to_everyone is false."
  default     = []
}

variable "conductorone_directory_app_id" {
  type        = string
  description = "App ID assigned to your identity provider (e.g. Okta) in ConductorOne."
}

variable "breakglass_group_name" {
  type        = string
  description = "Name of emergency/breakglass group with access to all entitlements."
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

variable "trigger" {
  type        = string
  description = "An MD5 hash used to trigger Terraform when changes are made to external data files."
}

variable "is_bundle" {
  type        = bool
  description = "Is this access profile a bundle/enrollment type. (T/F)"
  default     = false
}

variable "risk_level_low_id" {
  type        = string
  description = "ConductorOne risk level value ID for Low risk."
}

variable "risk_level_moderate_id" {
  type        = string
  description = "ConductorOne risk level value ID for Moderate risk."
}

variable "risk_level_high_id" {
  type        = string
  description = "ConductorOne risk level value ID for High risk."
}

variable "slug" {
  type        = string
  description = "Slug appended to bundle enrollment entitlement."
  default     = "enrollment"
}

variable "bundle_grant_policy_name" {
  type        = string
  description = "Display name of the grant/request policy to use for bundle enrollment entitlements."
  default     = "Self Approval Request Policy"
}

variable "bundle_revoke_policy_name" {
  type        = string
  description = "Display name of the revoke policy to use for bundle enrollment entitlements."
  default     = "Default Revoke Policy"
}

variable "all_entitlements" {
  description = "Map of all entitlement display names to their IDs."
}

variable "all_policies" {
  description = "Map of all policy display names to their IDs."
}

variable "all_access_profiles" {
  description = "Map of all access profile display names to their IDs."
}

variable "all_webhooks" {
  description = "Map of all webhook display names to their IDs."
}

variable "enrollment_behavior" {
  type        = string
  description = "Defines how to handle the request policies of the entitlements in the access profile during enrollment."
  default     = null
  validation {
    condition = var.enrollment_behavior == null ? true : contains([
      "REQUEST_CATALOG_ENROLLMENT_BEHAVIOR_UNSPECIFIED",
      "REQUEST_CATALOG_ENROLLMENT_BEHAVIOR_BYPASS_ENTITLEMENT_REQUEST_POLICY",
      "REQUEST_CATALOG_ENROLLMENT_BEHAVIOR_ENFORCE_ENTITLEMENT_REQUEST_POLICY"
    ], var.enrollment_behavior)
    error_message = "enrollment_behavior must be one of the specified values or null."
  }
}

variable "request_bundle" {
  type        = bool
  description = "Whether all the entitlements in the access profile can be requested at once (bundles feature required)."
  default     = null
}

variable "unenrollment_behavior" {
  type        = string
  description = "Defines how to handle revocation of entitlements during unenrollment."
  default     = null
  validation {
    condition = var.unenrollment_behavior == null ? true : contains([
      "REQUEST_CATALOG_UNENROLLMENT_BEHAVIOR_UNSPECIFIED",
      "REQUEST_CATALOG_UNENROLLMENT_BEHAVIOR_LEAVE_ACCESS_AS_IS",
      "REQUEST_CATALOG_UNENROLLMENT_BEHAVIOR_REVOKE_ALL",
      "REQUEST_CATALOG_UNENROLLMENT_BEHAVIOR_REVOKE_UNJUSTIFIED"
    ], var.unenrollment_behavior)
    error_message = "unenrollment_behavior must be one of the specified values or null."
  }
}

variable "unenrollment_entitlement_behavior" {
  type        = string
  description = "Defines how to handle revoke policies of entitlements during unenrollment."
  default     = null
  validation {
    condition = var.unenrollment_entitlement_behavior == null ? true : contains([
      "REQUEST_CATALOG_UNENROLLMENT_ENTITLEMENT_BEHAVIOR_UNSPECIFIED",
      "REQUEST_CATALOG_UNENROLLMENT_ENTITLEMENT_BEHAVIOR_BYPASS",
      "REQUEST_CATALOG_UNENROLLMENT_ENTITLEMENT_BEHAVIOR_ENFORCE"
    ], var.unenrollment_entitlement_behavior)
    error_message = "unenrollment_entitlement_behavior must be one of the specified values or null."
  }
}
