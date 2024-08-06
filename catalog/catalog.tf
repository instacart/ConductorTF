// Catalogs to be delegated through ConductorOne
// https://registry.terraform.io/providers/ConductorOne/conductorone/latest/docs/resources/catalog

# module "catalog" {
#
#   catalog_display_name        = "Name of the catalog."
#   catalog_description         = "Description of the catalog to be delegated."
#   catalog_active              = "Catalog is published and active. (T/F)"
#   catalog_visible_to_everyone = "Catalog is visible to all users. (T/F)"
#   catalog_users               = "If catalog_visible_to_everyone is false, this is a required field. Type name of Okta group."
#   entitlements                = "Specify Okta group memberships available to this catalog. See output of TF plan for up-to-date list"
#   breakglass_group_name       = "Name of 'Breakglass' Okta group that will have rights to all entitlements at all times."
#   catalog_options             = "Deprecated. Set catalog visibility within individual entitlements instead. See Access folder and YAML files.
#
# }

resource "conductorone_catalog" "catalog" {
  display_name        = var.catalog_display_name
  description         = var.catalog_description
  visible_to_everyone = var.catalog_visible_to_everyone
  published           = var.catalog_active
}

resource "conductorone_catalog_visibility_bindings" "catalog_visibility_bindings" {
  # Only proceed with original set if published is true, otherwise use an empty set
  for_each = var.catalog_active ? toset(concat(var.catalog_users, [var.breakglass_group_name])) : toset([])

  catalog_id = conductorone_catalog.catalog.id
  access_entitlements = [{
    app_id = var.conductorone_directory_app_id
    id     = lookup(local.entitlement_data, format("%s %s", each.value, "Group Member"))
    },
    {
      app_id = var.conductorone_directory_app_id
      id     = lookup(local.entitlement_data, format("%s %s", var.breakglass_group_name, "Group Member"))
  }]
}
