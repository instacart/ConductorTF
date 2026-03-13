# ConductorTF Access Profile Module

## Introduction

This Terraform module facilitates the creation and management of a ConductorOne access profile and its visibility bindings. The module supports both standard access profiles and bundle/enrollment-style access profiles, enabling flexible configuration of who can see and request access through the ConductorOne platform.

## Usage

```hcl
module "access_profile_data_science" {
  source = "./modules/access_profile"

  environment                        = var.environment
  trigger                            = local.master_hash
  conductorone_directory_app_id      = var.conductorone_directory_app_id
  access_profile_display_name        = "Dept Data Science"
  access_profile_description         = "Access that can be requested by members of the Data Science team."
  access_profile_active              = true
  access_profile_visible_to_everyone = false
  access_profile_users               = ["Dept Data Science"]
  breakglass_group_name              = var.breakglass_group_name

  all_entitlements    = var.all_entitlements
  all_policies        = var.all_policies
  all_access_profiles = var.all_access_profiles
  all_webhooks        = var.all_webhooks

  risk_level_low_id      = var.risk_level_low_id
  risk_level_moderate_id = var.risk_level_moderate_id
  risk_level_high_id     = var.risk_level_high_id
  conductorone_self_app_id = var.conductorone_self_app_id
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `environment` | The deployment environment. | `string` | N/A |
| `access_profile_display_name` | The display name for the access profile in ConductorOne. | `string` | N/A |
| `access_profile_description` | A brief description of the access profile. | `string` | N/A |
| `access_profile_visible_to_everyone` | Whether the access profile is visible to all users. | `bool` | N/A |
| `access_profile_active` | Whether the access profile is published and active. | `bool` | N/A |
| `access_profile_users` | List of groups with visibility to this access profile. | `list(string)` | `[]` |
| `conductorone_directory_app_id` | App ID for your identity provider in ConductorOne. | `string` | N/A |
| `conductorone_self_app_id` | ConductorOne platform application ID (required for bundles). | `string` | N/A |
| `breakglass_group_name` | Name of the emergency access group. | `string` | N/A |
| `entitlement_source` | Source of entitlements: `"okta"` or `"native"`. | `string` | `"okta"` |
| `is_bundle` | Whether this is a bundle/enrollment access profile. | `bool` | `false` |
| `risk_level_low_id` | ConductorOne risk level ID for Low risk. | `string` | N/A |
| `risk_level_moderate_id` | ConductorOne risk level ID for Moderate risk. | `string` | N/A |
| `risk_level_high_id` | ConductorOne risk level ID for High risk. | `string` | N/A |
| `bundle_grant_policy_name` | Grant policy name for bundle enrollment entitlements. | `string` | `"Self Approval Request Policy"` |
| `bundle_revoke_policy_name` | Revoke policy name for bundle enrollment entitlements. | `string` | `"Default Revoke Policy"` |
| `enrollment_behavior` | How to handle entitlement request policies during enrollment. | `string` | `null` |
| `request_bundle` | Whether all entitlements can be requested at once (bundles feature). | `bool` | `null` |
| `unenrollment_behavior` | How to handle entitlement revocation during unenrollment. | `string` | `null` |
| `unenrollment_entitlement_behavior` | How to handle revoke policies during unenrollment. | `string` | `null` |
| `all_entitlements` | Map of entitlement display names to IDs. | `any` | N/A |
| `all_policies` | Map of policy display names to IDs. | `any` | N/A |
| `all_access_profiles` | Map of access profile display names to IDs. | `any` | N/A |
| `all_webhooks` | Map of webhook display names to IDs. | `any` | N/A |
| `trigger` | MD5 hash to trigger Terraform on external data changes. | `string` | N/A |

## Outputs

| Name | Description |
|------|-------------|
| `access_profile_id` | The ID of the created access profile. |
| `access_profile_display_name` | The display name of the access profile. |
| `access_profile_name_to_id` | Map of access profile display name to ID, useful for lookups. |

## Bundle / Enrollment Access Profiles

When `is_bundle = true`, this module creates a bundle-style access profile where all included entitlements can be requested together. The bundle enrollment entitlement is configured with a self-approval grant policy so that individual entitlement request policies still apply.

## External Data

This module requires pre-loaded maps of ConductorOne resource data (`all_entitlements`, `all_policies`, `all_access_profiles`, `all_webhooks`). These are typically populated from ConductorOne API data synced via a script and passed in from the root module.

## Contributing

Contributions to this module are welcome. Please open an issue or pull request.
