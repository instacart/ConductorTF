// Entitlements to be managed through ConductorOne
// https://registry.terraform.io/providers/ConductorOne/conductorone/latest/docs/resources/entitlement

# module "entitlement" {
#
#     entitlement_source                  = "Use 'okta' for access dependent upon IdP group membership. Use 'native' for apps with direct integrations with C1."
#     conductorone_directory_app_id       = "Unique ID assigned to the IdP tenant integrated with C1."
#     entitlement_name                    = "Name of the access entitlement. This is likely the name of an existing IdP group."
#     entitlement_description             = "Description of the access entitlement. Ex. 'This is the XYZ Role which provides access to A,B,C.'"
#     maximum_duration_grant              = "Maximum length of time an entitlement may be granted, defined in seconds. Ex. 604800s = 1 week."
#     access_profiles                     = "List of access profile names that an entitlement should belong to."
#     request_policy                      = "Request/Grant Policy (display name)"
#     review_policy                       = "Review/Certification Policy (display name)"
#     revoke_policy                       = "Revoke/Removal Policy (display name)"
#
# }

resource "conductorone_app_entitlement" "entitlement" {
  count               = var.webhook_provision == false && var.multistep_webhook_provision == false && local.maximum_duration_grant != "0s" && local.maximum_duration_grant != "3153600000s" ? 1 : 0
  id                  = local.entitlement_id
  alias               = local.alias
  app_id              = local.target_app_id
  description         = var.entitlement_description
  risk_level_value_id = var.risk_level
  slug                = var.slug
  provision_policy = {
    connector_provision = {}
  }

  // duration_grant is "maximum" duration grant. default: 1 week = 604800s
  duration_grant            = local.maximum_duration_grant
  grant_policy_id           = lookup(local.policy_data, var.request_policy)
  certify_policy_id         = lookup(local.policy_data, var.review_policy)
  revoke_policy_id          = lookup(local.policy_data, var.revoke_policy)
  emergency_grant_enabled   = var.emergency_grant_enabled
  emergency_grant_policy_id = var.emergency_grant_enabled ? lookup(local.policy_data, var.emergency_grant_policy_name) : ""
}

resource "conductorone_app_entitlement" "indefinite_entitlement" {
  count               = var.webhook_provision == false && var.multistep_webhook_provision == false && (local.maximum_duration_grant == "0s" || local.maximum_duration_grant == "3153600000s") ? 1 : 0
  id                  = local.entitlement_id
  alias               = local.alias
  app_id              = local.target_app_id
  description         = var.entitlement_description
  risk_level_value_id = var.risk_level
  slug                = var.slug
  provision_policy = {
    connector_provision = {}
  }

  // duration_unset sets duration maximum as indefinite
  duration_unset            = {}
  grant_policy_id           = lookup(local.policy_data, var.request_policy)
  certify_policy_id         = lookup(local.policy_data, var.review_policy)
  revoke_policy_id          = lookup(local.policy_data, var.revoke_policy)
  emergency_grant_enabled   = var.emergency_grant_enabled
  emergency_grant_policy_id = var.emergency_grant_enabled ? lookup(local.policy_data, var.emergency_grant_policy_name) : ""
}

resource "conductorone_app_entitlement" "multistep_webhook_entitlement" {
  count               = var.multistep_webhook_provision == true ? 1 : 0
  id                  = local.entitlement_id
  alias               = local.alias
  app_id              = local.target_app_id
  description         = var.entitlement_description
  risk_level_value_id = var.risk_level
  slug                = var.slug
  provision_policy = {
    "multi_step" = jsonencode({
      "provisionSteps" : [
        {
          "webhook" : {
            "webhookId" : var.webhook_provision_id
          }
        },
        {
          "connector" : {}
        }
      ]
    })
  }

  // duration_grant is "maximum" duration grant. default: 1 week = 604800s
  duration_grant            = local.maximum_duration_grant
  grant_policy_id           = lookup(local.policy_data, var.request_policy)
  certify_policy_id         = lookup(local.policy_data, var.review_policy)
  revoke_policy_id          = lookup(local.policy_data, var.revoke_policy)
  emergency_grant_enabled   = var.emergency_grant_enabled
  emergency_grant_policy_id = var.emergency_grant_enabled ? lookup(local.policy_data, var.emergency_grant_policy_name) : ""
}

resource "conductorone_app_entitlement" "webhook_entitlement" {
  count               = ((var.entitlement_source != "okta") && var.webhook_provision == true) ? 1 : 0
  id                  = local.entitlement_id
  alias               = local.alias
  app_id              = local.target_app_id
  description         = var.entitlement_description
  risk_level_value_id = var.risk_level
  slug                = var.slug
  provision_policy = {
    webhook_provision = {
      "webhook_id" : var.webhook_provision_id
    }
  }

  // duration_grant is "maximum" duration grant. default: 1 week = 604800s
  duration_grant            = local.maximum_duration_grant
  grant_policy_id           = lookup(local.policy_data, var.request_policy)
  certify_policy_id         = lookup(local.policy_data, var.review_policy)
  revoke_policy_id          = lookup(local.policy_data, var.revoke_policy)
  emergency_grant_enabled   = var.emergency_grant_enabled
  emergency_grant_policy_id = var.emergency_grant_enabled ? lookup(local.policy_data, var.emergency_grant_policy_name) : ""
}

resource "conductorone_access_profile_requestable_entries" "access_profile_requestable_entries" {
  for_each   = toset(var.access_profiles)
  catalog_id = lookup(local.access_profile_data, each.value)

  app_entitlements = (var.entitlement_source == "okta") ? (
    var.webhook_provision == false && var.multistep_webhook_provision == false && var.additional_entitlement_required == false && local.maximum_duration_grant != "0s" && local.maximum_duration_grant != "3153600000s" ? [{
      app_id = data.conductorone_app.mirror_app.id
      id     = conductorone_custom_app_entitlement.mirror_app_entitlement[0].id
      }] : var.multistep_webhook_provision == true ? [{
      app_id = data.conductorone_app.mirror_app.id
      id     = conductorone_custom_app_entitlement.mirror_multistep_webhook_app_entitlement[0].id
      }] : var.additional_entitlement_required == true ? [{
      app_id = data.conductorone_app.mirror_app.id
      id     = conductorone_custom_app_entitlement.mirror_with_additional_entitlement[0].id
      }] : local.maximum_duration_grant == "0s" || local.maximum_duration_grant == "3153600000s" ? [{
      app_id = data.conductorone_app.mirror_app.id
      id     = conductorone_custom_app_entitlement.mirror_app_indefinite_entitlement[0].id
      }] : [{
      app_id = data.conductorone_app.mirror_app.id
      id     = conductorone_custom_app_entitlement.mirror_webhook_app_entitlement[0].id
    }]
    ) : [{
      app_id = local.target_app_id
      id     = local.entitlement_id
  }]
}

resource "conductorone_access_profile_requestable_entries" "mirror_access_profile_requestable_entries" {
  for_each   = local.mirrored_access_profiles_to_process
  catalog_id = lookup(local.access_profile_data, each.value)

  app_entitlements = (var.entitlement_source != "okta") ? (
    var.webhook_provision == false ? [{
      app_id = data.conductorone_app.mirror_app.id
      id     = conductorone_custom_app_entitlement.mirror_app_entitlement[0].id
      }] : var.multistep_webhook_provision == true ? [{
      app_id = data.conductorone_app.mirror_app.id
      id     = conductorone_custom_app_entitlement.mirror_multistep_webhook_app_entitlement[0].id
      }] : var.additional_entitlement_required == true ? [{
      app_id = data.conductorone_app.mirror_app.id
      id     = conductorone_custom_app_entitlement.mirror_with_additional_entitlement[0].id
      }] : local.maximum_duration_grant == "0s" || local.maximum_duration_grant == "3153600000s" ? [{
      app_id = data.conductorone_app.mirror_app.id
      id     = conductorone_custom_app_entitlement.mirror_app_indefinite_entitlement[0].id
      }] : [{
      app_id = data.conductorone_app.mirror_app.id
      id     = conductorone_custom_app_entitlement.mirror_webhook_app_entitlement[0].id
    }]
    ) : [{
      app_id = local.target_app_id
      id     = local.entitlement_id
  }]
}

# ######################################################################################################
# ### MIRRORED ENTITLEMENTS                                                                            #
# ### When an application is dependent upon IdP-based entitlements, create a mirrored/linked          #
# ### custom entitlement to reflect this entitlement as a separate app dropdown in the C1 UI.         #
# ######################################################################################################
resource "conductorone_custom_app_entitlement" "mirror_app_entitlement" {
  count                = ((var.entitlement_source == "okta") && var.mirrored_application_name != "Okta" && var.webhook_provision == false && var.multistep_webhook_provision == false && var.additional_entitlement_required == false && local.maximum_duration_grant != "0s" && local.maximum_duration_grant != "3153600000s") ? 1 : 0
  display_name         = var.entitlement_alternate_name != "None" ? var.entitlement_alternate_name : local.entitlement_name
  app_id               = data.conductorone_app.mirror_app.id
  app_resource_id      = conductorone_app_resource.mirrored_app_resource[0].id
  app_resource_type_id = var.mirrored_application_resource_type_id
  alias                = local.alias
  provision_policy = {
    delegated_provision = {
      app_id         = local.target_app_id
      entitlement_id = local.entitlement_id
    }
  }
  risk_level_value_id = var.risk_level
  slug                = var.slug
  description         = var.entitlement_description
  grant_policy_id     = lookup(local.policy_data, var.request_policy)
  certify_policy_id   = lookup(local.policy_data, var.review_policy)
  revoke_policy_id    = lookup(local.policy_data, var.revoke_policy)
  duration_grant      = local.maximum_duration_grant
}

resource "conductorone_custom_app_entitlement" "mirror_app_indefinite_entitlement" {
  count                = ((var.entitlement_source == "okta") && var.mirrored_application_name != "Okta" && var.webhook_provision == false && var.multistep_webhook_provision == false && var.additional_entitlement_required == false && (local.maximum_duration_grant == "0s" || local.maximum_duration_grant == "3153600000s")) ? 1 : 0
  display_name         = var.entitlement_alternate_name != "None" ? var.entitlement_alternate_name : local.entitlement_name
  app_id               = data.conductorone_app.mirror_app.id
  app_resource_id      = conductorone_app_resource.mirrored_app_resource[0].id
  app_resource_type_id = var.mirrored_application_resource_type_id
  alias                = local.alias
  description          = var.entitlement_description
  risk_level_value_id  = var.risk_level
  slug                 = var.slug
  provision_policy = {
    delegated_provision = {
      app_id         = local.target_app_id
      entitlement_id = local.entitlement_id
    }
  }

  // duration_unset sets duration maximum as indefinite
  duration_unset    = {}
  grant_policy_id   = lookup(local.policy_data, var.request_policy)
  certify_policy_id = lookup(local.policy_data, var.review_policy)
  revoke_policy_id  = lookup(local.policy_data, var.revoke_policy)
}

resource "conductorone_custom_app_entitlement" "mirror_webhook_app_entitlement" {
  count                = ((var.entitlement_source == "okta") && var.mirrored_application_name != "Okta" && var.webhook_provision == true) ? 1 : 0
  display_name         = var.entitlement_alternate_name != "None" ? var.entitlement_alternate_name : local.entitlement_name
  app_id               = data.conductorone_app.mirror_app.id
  app_resource_id      = conductorone_app_resource.mirrored_app_resource[0].id
  app_resource_type_id = var.mirrored_application_resource_type_id
  alias                = local.alias
  provision_policy = {
    webhook_provision = {
      "webhook_id" : var.webhook_provision_id
    }
  }
  risk_level_value_id = var.risk_level
  slug                = var.slug
  description         = var.entitlement_description
  grant_policy_id     = lookup(local.policy_data, var.request_policy)
  certify_policy_id   = lookup(local.policy_data, var.review_policy)
  revoke_policy_id    = lookup(local.policy_data, var.revoke_policy)
  duration_grant      = local.maximum_duration_grant
}

resource "conductorone_custom_app_entitlement" "mirror_multistep_webhook_app_entitlement" {
  count                = ((var.entitlement_source == "okta") && var.mirrored_application_name != "Okta" && var.multistep_webhook_provision == true) ? 1 : 0
  display_name         = var.entitlement_alternate_name != "None" ? var.entitlement_alternate_name : local.entitlement_name
  app_id               = data.conductorone_app.mirror_app.id
  app_resource_id      = conductorone_app_resource.mirrored_app_resource[0].id
  app_resource_type_id = var.mirrored_application_resource_type_id
  alias                = local.alias
  provision_policy = {
    delegated_provision = {
      app_id         = local.target_app_id
      entitlement_id = local.entitlement_id
    }
  }
  risk_level_value_id = var.risk_level
  slug                = var.slug
  description         = var.entitlement_description
  grant_policy_id     = lookup(local.policy_data, var.request_policy)
  certify_policy_id   = lookup(local.policy_data, var.review_policy)
  revoke_policy_id    = lookup(local.policy_data, var.revoke_policy)
  duration_grant      = local.maximum_duration_grant
}

resource "conductorone_custom_app_entitlement" "mirror_with_additional_entitlement" {
  count                = ((var.entitlement_source == "okta") && var.mirrored_application_name != "Okta" && var.additional_entitlement_required == true) ? 1 : 0
  display_name         = var.entitlement_alternate_name != "None" ? var.entitlement_alternate_name : local.entitlement_name
  app_id               = data.conductorone_app.mirror_app.id
  app_resource_id      = conductorone_app_resource.mirrored_app_resource[0].id
  app_resource_type_id = var.mirrored_application_resource_type_id
  alias                = local.alias
  provision_policy = {
    "multi_step" = jsonencode({
      "provisionSteps" : [
        {
          "delegated" : {
            "appId" : var.conductorone_directory_app_id
            "entitlementId" : local.additional_entitlement_id
            "implicit" : false
          }
        },
        {
          "delegated" : {
            "appId" : local.target_app_id
            "entitlementId" : local.entitlement_id
            "implicit" : false
          }
        }
      ]
    })
  }
  risk_level_value_id = var.risk_level
  slug                = var.slug
  description         = var.entitlement_description
  grant_policy_id     = lookup(local.policy_data, var.request_policy)
  certify_policy_id   = lookup(local.policy_data, var.review_policy)
  revoke_policy_id    = lookup(local.policy_data, var.revoke_policy)
  duration_grant      = local.maximum_duration_grant
}

resource "conductorone_app_resource" "mirrored_app_resource" {
  count                = ((var.entitlement_source == "okta") && var.mirrored_application_name != "Okta") ? 1 : 0
  display_name         = var.entitlement_alternate_name != "None" ? var.entitlement_alternate_name : local.entitlement_name
  app_resource_type_id = var.mirrored_application_resource_type_id
  description          = var.entitlement_description
  app_id               = data.conductorone_app.mirror_app.id
}

resource "conductorone_app_entitlement_proxy_binding" "mirror_webhook_binding" {
  count                  = ((var.entitlement_source == "okta") && var.mirrored_application_name != "Okta" && var.webhook_provision == true) ? 1 : 0
  src_app_id             = local.target_app_id
  src_app_entitlement_id = local.entitlement_id
  dst_app_id             = data.conductorone_app.mirror_app.id
  dst_app_entitlement_id = conductorone_custom_app_entitlement.mirror_webhook_app_entitlement[0].id
}

resource "conductorone_app_entitlement_proxy_binding" "mirror_multistep_webhook_binding" {
  count                  = ((var.entitlement_source == "okta") && var.mirrored_application_name != "Okta" && var.multistep_webhook_provision == true) ? 1 : 0
  src_app_id             = local.target_app_id
  src_app_entitlement_id = local.entitlement_id
  dst_app_id             = data.conductorone_app.mirror_app.id
  dst_app_entitlement_id = conductorone_custom_app_entitlement.mirror_multistep_webhook_app_entitlement[0].id
}

resource "conductorone_app_entitlement_proxy_binding" "mirror_with_additional_entitlement_binding" {
  count                  = ((var.entitlement_source == "okta") && var.mirrored_application_name != "Okta" && var.additional_entitlement_required == true && (local.additional_entitlement_id != local.entitlement_id)) ? 1 : 0
  src_app_id             = local.target_app_id
  src_app_entitlement_id = local.entitlement_id
  dst_app_id             = data.conductorone_app.mirror_app.id
  dst_app_entitlement_id = conductorone_custom_app_entitlement.mirror_with_additional_entitlement[0].id
}

resource "conductorone_app_entitlement_proxy_binding" "mirror_indefinite_entitlement_binding" {
  count                  = ((var.entitlement_source == "okta") && var.mirrored_application_name != "Okta" && var.additional_entitlement_required == true && (local.additional_entitlement_id != local.entitlement_id) && (local.maximum_duration_grant == "0s" || local.maximum_duration_grant == "3153600000s")) ? 1 : 0
  src_app_id             = local.target_app_id
  src_app_entitlement_id = local.entitlement_id
  dst_app_id             = data.conductorone_app.mirror_app.id
  dst_app_entitlement_id = conductorone_custom_app_entitlement.mirror_app_indefinite_entitlement[0].id
}

resource "conductorone_app_entitlement_proxy_binding" "mirror_binding" {
  count                  = ((var.entitlement_source == "okta") && var.mirrored_application_name != "Okta" && var.webhook_provision == false && var.multistep_webhook_provision == false && var.additional_entitlement_required == false && local.maximum_duration_grant != "0s" && local.maximum_duration_grant != "3153600000s") ? 1 : 0
  src_app_id             = local.target_app_id
  src_app_entitlement_id = local.entitlement_id
  dst_app_id             = data.conductorone_app.mirror_app.id
  dst_app_entitlement_id = conductorone_custom_app_entitlement.mirror_app_entitlement[0].id
}
