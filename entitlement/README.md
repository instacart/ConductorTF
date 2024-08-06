# ConductorTF Entitlement Module

## Introduction

The Terraform Entitlements Module is designed for managing access entitlements through ConductorOne, specifically for integrating Okta group memberships or native app integrations. This module automates the process of creating, managing, and assigning entitlements within specified catalogs, as well as linking them to request, review, and revoke policies.

## Usage

This is a technical reference. To utilize this module, or to **Add/Change** an entitlement, please instead use the designated YAML files provided in the `conductorone/access` folder. The YAML files are ingested by this module. 

To fully **Remove** an entitlement from ConductorOne, the entity must be removed from the source. ie. An Okta group would need to be removed from Okta in order for the entitlement to disappear from C1. Instead, best practice is to remove visibility from an entitlement by eliminating any entries from `catalog_visibility` in the corresponding YAML file. These can be found in the `conductorone/access` folder.

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `environment` | Deployment environment | `string` | N/A |
| `entitlement_name` | Name of the entitlement | `string` | N/A |
| `conductorone_directory_app_id` | Unique ID for the Okta tenant | `string` | N/A |
| `maximum_duration_grant` | Maximum grant duration in seconds | `string` | `"604800s"` |
| `slug` | Slug to append at the end of the entitlement | `string` | `"member"` |
| `entitlement_description` | Description of the entitlement | `string` | N/A |
| `entitlement_source` | Entitlement source: "okta" for Okta groups, "native" for direct integrations | `string` | `"okta"` |
| `catalogs` | List of catalog names the entitlement belongs to | `list(string)` | [] |
| `request_policy` | Display name of the request/grant policy | `string` | N/A |
| `review_policy` | Display name of the review/certification policy | `string` | N/A |
| `revoke_policy` | Display name of the revoke/removal policy | `string` | N/A |
| `emergency_grant_enabled` | Whether the emergency policy is enabled | `bool` | N/A |
| `emergency_grant_policy_name` | Name of the emergency grant policy | `string` | "" |
| `trigger` | MD5 hash used to trigger Terraform on YAML file changes | `string` | N/A |

## External Sources

This module is currently dependent upon external data sources from ConductorOne which pull and store data into json files. The following json files must be up-to-date to ensure successful entitlement deployment.

See `c1-data-sync.sh`

- c1-data-sync-catalogs.json
- c1-data-sync-entitlements.json
- c1-data-sync-policies.json

## YAML Example

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name` | Name of the entitlement. This must match an existing Okta/Application group. | `string` | N/A |
| `entitlement_name` | Name of the entitlement | `string` | N/A |
| `catalog_visibility` | List of catalogs which may view/request the entitlement. | `list(string)` | N/A |
| `maximum_duration_grant` | Maximum duration of time a user may request the entitlement. Must be defined in seconds. | `string` | N/A |
| `request_policy` | The policy defines users who may grant the request for the entitlement. | `string` | N/A |
| `review_policy` | The policy defines who reviews/certifies requests for the entitlement. | `string` | N/A |
| `revoke_policy` | The policy defines when the entitlement is removed. | `string` | N/A |
| `emergency_grant_policy_enabled` | Emergency access enabled? | `bool` | N/A |
| `emergency_grant_policy_name` | Emergency access policy name must match an existing policy name. | `string` | N/A |

```yaml
  - 
    name: "AWS-Developer"
    description: 'AWS Developer role used by default for SWE. This is a baseline AWS role for all developers/software developers.'
    catalog_visibility:
      - "Team Engineering"
      - "Team Security"
    maximum_duration_grant: "7776000s"
    policy:
      request_policy: "Self Approval Request Policy"
      review_policy: "Self Certified Review Policy"
      revoke_policy: "Default Revoke Policy"
      emergency_grant_policy_enabled: True
      emergency_grant_policy_name: "EmergencyAccessPolicy:Self"
```

## Contributing

Contributions to this module are welcome.