# ConductorTF Catalog Module

## Introduction

This Terraform module facilitates the creation and management of a ConductorOne catalog and its visibility bindings based on predefined criteria. The module is designed to streamline the configuration of catalogs, making them accessible to selected groups, and managing their visibility and status efficiently.

## Usage

To use this module, **Add/Change/Remove** the following configuration to catalog-teams.tf:

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `environment` | The deployment environment. This is derived by Atlantis. | `string` | N/A |
| `catalog_display_name` | The display name for the catalog that appears on the C1 Platform. | `string` | N/A |
| `catalog_description` | A brief description of the catalog. | `string` | N/A |
| `catalog_visible_to_everyone` | Boolean value to make the catalog visible to everyone. | `bool` | N/A |
| `catalog_active` | Boolean value to activate the catalog. | `bool` | N/A |
| `catalog_users` | A list of user groups with access to the catalog. These are typically Okta groups and must be an exact match. | `list(string)` | [] |
| `conductorone_directory_app_id` | The app ID to the IdP assigned within ConductorOne, this is derived by the `environment` variable. | `string` | N/A |
| `breakglass_group_name` | The name of the emergency access group. These are typically Okta groups and must be an exact match. | `string` | N/A |

## Outputs

The module defines the following output:

- `catalog_id`: The identifier of the created catalog.

## Example

Below is an example of how to use this module:

```hcl
module "catalog-data-science" {
  source                        = "../_modules/conductorone/catalog"
  environment                   = var.environment
  trigger                       = local.master_hash
  conductorone_directory_app_id = var.conductorone_directory_app_id
  catalog_display_name          = "Dept Data Science"
  catalog_description           = "Access that can be requested by members of Data Science team."
  catalog_active                = true
  catalog_visible_to_everyone   = false
  catalog_users                 = ["Dept Data Science"]
  breakglass_group_name         = var.breakglass_group_name
}
```

## External Sources

This module is currently dependent upon external data sources from ConductorOne which pull and store data into json files. The following json files must be up-to-date to ensure successful catalog deployment.

See `c1-data-sync.sh`

- c1-data-sync-catalogs.json
- c1-data-sync-entitlements.json
- c1-data-sync-policies.json

## Contributing

Contributions to this module are welcome.
