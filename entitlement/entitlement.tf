// Entitlements to be delegated through ConductorOne
// https://registry.terraform.io/providers/ConductorOne/conductorone/latest/docs/resources/entitlement

# module "entitlement" {
#
#     entitlement_source                  = "Use "Okta" for access dependent upon Okta group membership. Use "Native" for apps with direct integrations with C1."
#     conductorone_directory_app_id       = "Unique ID assigned to the Okta tenant integrated with C1. Dependent upon environment."
#     entitlement_name                    = "Name of the access entitlement. This is likely the name of an existing Okta group."
#     entitlement_description             = "Description of the access entitlement. Ex. 'This is the XYZ AWS Role which provides access to A,B,C.'"
#     maximum_duration_grant              = "Maximum length of time an entitlement may be granted, defined in seconds. Ex. 604800s = 1 week."
#     catalogs                            = "List of catalog names that an entitlement should belong to."
#     request_policy                      = "Request/Grant Policy (display name)"
#     review_policy                       = "Review/Certification Policy (display name)"
#     revoke_policy                       = "Revoke/Removal Policy (display name)"
#
# }

resource "conductorone_app_entitlement" "entitlement" {
  id                  = local.entitlement_id
  alias               = replace(replace(lower(var.entitlement_name), " ", "-"), ":", "-")
  app_id              = var.conductorone_directory_app_id
  description         = var.entitlement_description
  risk_level_value_id = var.risk_level
  slug                = var.slug
  provision_policy = {
    connector_provision = {}
  }
  // duration_grant is "maximum" duration grant. default: 1 week = 604800s
  duration_grant            = var.maximum_duration_grant
  grant_policy_id           = lookup(local.policy_data, var.request_policy)
  certify_policy_id         = lookup(local.policy_data, var.review_policy)
  revoke_policy_id          = lookup(local.policy_data, var.revoke_policy)
  emergency_grant_enabled   = var.emergency_grant_enabled
  emergency_grant_policy_id = var.emergency_grant_enabled ? lookup(local.policy_data, var.emergency_grant_policy_name) : ""
}

resource "conductorone_catalog_requestable_entries" "catalog_requestable_entries" {
  for_each   = toset(var.catalogs)
  catalog_id = lookup(local.catalog_data, each.value)
  app_entitlements = [{
    app_id = var.conductorone_directory_app_id
    id     = local.entitlement_id
  }]
}
