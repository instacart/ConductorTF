// Access Profiles (Catalogs) to be managed through ConductorOne
// https://registry.terraform.io/providers/ConductorOne/conductorone/latest/docs/resources/access_profile

# module "access_profile" {
#
#   access_profile_display_name        = "Name of the access profile."
#   access_profile_description         = "Description of the access profile."
#   access_profile_active              = "Access profile is published and active. (T/F)"
#   access_profile_visible_to_everyone = "Access profile is visible to all users. (T/F)"
#   access_profile_users               = "If access_profile_visible_to_everyone is false, this is a required field. List of group names."
#   breakglass_group_name              = "Name of emergency/breakglass group that will have rights to all entitlements at all times."
#   is_bundle                          = "Whether this access profile is a bundle/enrollment type. (T/F)"
#
# }

resource "conductorone_access_profile" "access_profile" {
  count                             = var.is_bundle != true ? 1 : 0
  display_name                      = var.access_profile_display_name
  description                       = var.access_profile_description
  visible_to_everyone               = var.access_profile_visible_to_everyone
  published                         = var.access_profile_active
  enrollment_behavior               = var.enrollment_behavior
  request_bundle                    = var.request_bundle
  unenrollment_behavior             = var.unenrollment_behavior
  unenrollment_entitlement_behavior = var.unenrollment_entitlement_behavior
}

resource "conductorone_access_profile" "access_profile_bundle" {
  count                             = var.is_bundle == true ? 1 : 0
  display_name                      = var.access_profile_display_name
  description                       = var.access_profile_description
  visible_to_everyone               = var.access_profile_visible_to_everyone
  published                         = var.access_profile_active
  enrollment_behavior               = var.enrollment_behavior
  request_bundle                    = var.request_bundle
  unenrollment_behavior             = var.unenrollment_behavior
  unenrollment_entitlement_behavior = var.unenrollment_entitlement_behavior
}

resource "conductorone_access_profile_visibility_bindings" "access_profile_visibility_bindings" {
  for_each = var.access_profile_active && var.is_bundle != true ? toset(concat(var.access_profile_users, [var.breakglass_group_name])) : toset([])

  catalog_id = conductorone_access_profile.access_profile[0].id
  access_entitlements = [{
    app_id = local.target_app_id
    id     = var.entitlement_source == "okta" ? lookup(local.entitlement_data, format("%s %s", each.value, "Group Member"), null) : lookup(local.entitlement_data, each.value, null)
    },
    {
      app_id = var.conductorone_directory_app_id
      id     = lookup(local.entitlement_data, format("%s %s", var.breakglass_group_name, "Group Member"), null)
  }]
}

resource "conductorone_access_profile_visibility_bindings" "access_profile_visibility_bindings_bundle" {
  for_each = var.access_profile_active && var.is_bundle == true ? toset(concat(var.access_profile_users, [var.breakglass_group_name])) : toset([])

  catalog_id = conductorone_access_profile.access_profile_bundle[0].id
  access_entitlements = [{
    app_id = local.target_app_id
    id     = var.entitlement_source == "okta" ? lookup(local.entitlement_data, format("%s %s", each.value, "Group Member"), null) : lookup(local.entitlement_data, each.value, null)
    },
    {
      app_id = var.conductorone_directory_app_id
      id     = lookup(local.entitlement_data, format("%s %s", var.breakglass_group_name, "Group Member"), null)
  }]
}

resource "conductorone_app_entitlement" "access_profile_bundle_enrollment" {
  # If access profile is a bundle/enrollment, set request policy as self-approval to ensure
  # pass-through to entitlement-based request policies.
  count               = var.is_bundle == true && local.bundle_entitlement_id != "None" ? 1 : 0
  id                  = local.bundle_entitlement_id
  alias               = local.bundle_entitlement_alias
  app_id              = var.conductorone_self_app_id
  description         = var.access_profile_display_name
  risk_level_value_id = var.risk_level_low_id
  slug                = var.slug

  grant_policy_id  = lookup(local.policy_data, var.bundle_grant_policy_name)
  revoke_policy_id = lookup(local.policy_data, var.bundle_revoke_policy_name)
}
