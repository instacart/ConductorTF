# ConductorTF Entitlement Module

## Introduction

This Terraform module manages access entitlements through ConductorOne, supporting IdP group memberships (e.g. Okta), native app integrations, webhook-based provisioning, mirrored applications, and multi-step provisioning workflows.

## Usage

This is a technical reference. To utilize this module, or to **Add/Change** an entitlement, use the designated YAML files in your `conductorone/access` folder. The YAML files are ingested by a root module that calls this module.

To fully **Remove** an entitlement from ConductorOne, the entity must be removed from the source application. Best practice is to first remove visibility by eliminating entries from `access_profile` membership in the corresponding YAML file, then remove the entitlement definition in a subsequent change.

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `environment` | Deployment environment | `string` | N/A |
| `entitlement_name` | Name of the entitlement | `string` | N/A |
| `entitlement_alternate_name` | Alternate display name for mirrored entitlements | `string` | `"None"` |
| `conductorone_directory_app_id` | App ID for your IdP in ConductorOne | `string` | N/A |
| `target_app_id` | App ID for native integrations | `string` | `""` |
| `mirrored_application_name` | Display name of the mirrored app in C1 | `string` | `"Okta"` |
| `mirrored_application_resource_type_id` | Resource type ID for GROUP in the mirrored app | `string` | `"2e40qJR3fvmcnnv5hC85lrGpIWq"` |
| `mirrored_app` | Whether this is a mirrored application for UI purposes | `bool` | `true` |
| `maximum_duration_grant` | Maximum grant duration in seconds. Use `"0s"` for indefinite. | `string` | `"604800s"` |
| `risk_level` | Risk level value ID assigned to the entitlement | `string` | N/A |
| `slug` | Slug appended to the entitlement identifier | `string` | `"member"` |
| `entitlement_description` | Description of the entitlement | `string` | N/A |
| `entitlement_source` | Source: `"okta"` for IdP group membership, `"native"` for direct app integrations | `string` | `"okta"` |
| `access_profiles` | List of access profile names this entitlement belongs to | `list(string)` | `[]` |
| `request_policy` | Display name of the request/grant policy | `string` | N/A |
| `review_policy` | Display name of the review/certification policy | `string` | N/A |
| `revoke_policy` | Display name of the revoke/removal policy | `string` | N/A |
| `emergency_grant_enabled` | Whether the emergency policy is enabled | `bool` | N/A |
| `emergency_grant_policy_name` | Display name of the emergency grant policy | `string` | `""` |
| `webhook_provision` | Whether provisioning is via a webhook | `bool` | `false` |
| `multistep_webhook_provision` | Whether provisioning uses webhook + connector | `bool` | `false` |
| `webhook_provision_id` | ID of the webhook used for provisioning | `string` | `"None"` |
| `additional_entitlement_required` | Whether a linked additional entitlement is needed | `bool` | `false` |
| `additional_entitlement_name` | Name of the additional entitlement | `string` | `"None"` |
| `conductorone_service_account_email` | Email of the ConductorOne service account | `string` | N/A |
| `all_entitlements` | Map of entitlement display names to IDs | `any` | N/A |
| `all_policies` | Map of policy display names to IDs | `any` | N/A |
| `all_access_profiles` | Map of access profile display names to IDs | `any` | N/A |
| `all_webhooks` | Map of webhook display names to IDs | `any` | N/A |
| `trigger` | MD5 hash used to trigger Terraform on external data changes | `string` | N/A |

## External Data

This module requires pre-loaded maps of ConductorOne resource data (`all_entitlements`, `all_policies`, `all_access_profiles`, `all_webhooks`). These should be synced from the ConductorOne API and passed in from the root module.

## YAML Example

```yaml
  -
    name: "AWS-Developer"
    description: 'AWS Developer role. Baseline AWS role for all developers.'
    access_profiles:
      - "Team Engineering"
      - "Team Security"
    maximum_duration_grant: "7776000s"
    policy:
      request_policy: "Self Approval Request Policy"
      review_policy: "Self Certified Review Policy"
      revoke_policy: "Default Revoke Policy"
      emergency_grant_policy_enabled: true
      emergency_grant_policy_name: "EmergencyAccessPolicy:Self"
```

## Mirrored Applications

When an application uses IdP-based entitlements (e.g. Okta group membership), you can create a mirrored custom entitlement that reflects the IdP entitlement under a separate application in the C1 UI. Set `mirrored_application_name` to the display name of the target app and `mirrored_app = true`.

## Contributing

Contributions to this module are welcome. Please open an issue or pull request.
