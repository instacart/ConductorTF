locals {
  access_profile_data = var.all_access_profiles
  entitlement_data    = var.all_entitlements
  policy_data         = var.all_policies
  webhook_data        = var.all_webhooks

  risk_level_ids = {
    "Low"      = var.risk_level_low_id
    "Moderate" = var.risk_level_moderate_id
    "High"     = var.risk_level_high_id
  }

  target_app_id            = var.entitlement_source == "okta" ? var.conductorone_directory_app_id : var.target_app_id
  bundle_entitlement_id    = var.is_bundle == true ? lookup(local.entitlement_data, var.access_profile_display_name, "None") : "None"
  bundle_entitlement_alias = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(lower(var.access_profile_display_name), " on project id: projects", ""), ":", ""), "/", ""), "-", ""), "_", ""), " ", ""), "&", ""), "'", ""), ",", ""), ".", ""), "(", ""), ")", "")
}
