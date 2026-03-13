locals {
  access_profile_data = var.all_access_profiles
  entitlement_data    = var.all_entitlements
  policy_data         = var.all_policies
  webhook_data        = var.all_webhooks

  entitlement_name          = var.entitlement_name
  entitlement_id            = var.entitlement_source == "okta" ? lookup(local.entitlement_data, format("%s %s", var.entitlement_name, "Group Member")) : lookup(local.entitlement_data, var.entitlement_name)
  additional_entitlement_id = var.additional_entitlement_required ? lookup(local.entitlement_data, format("%s %s", var.additional_entitlement_name, "Group Member")) : "None"
  target_app_id             = var.entitlement_source == "okta" ? var.conductorone_directory_app_id : var.target_app_id

  mirrored_access_profiles_to_process = var.mirrored_app ? toset(var.access_profiles) : []

  entitlement_alias = replace(replace(lower(var.entitlement_name), " on project id: projects", ""), "/[^a-z0-9]/", "")
  alias             = length(local.entitlement_alias) > 63 ? substr(local.entitlement_alias, 0, 63) : local.entitlement_alias

  # this is the value recommended by ConductorOne to reflect infinite duration.
  maximum_duration_grant = var.maximum_duration_grant == "0s" ? "3153600000s" : var.maximum_duration_grant
}
