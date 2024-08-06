locals {
  catalog_data_json     = jsondecode(file("${path.cwd}/external/catalog.json"))["data"][0]
  entitlement_data_json = jsondecode(file("${path.cwd}/external/entitlement.json"))["data"][0]
  policy_data_json      = jsondecode(file("${path.cwd}/external/policy.json"))["data"][0]

  catalog_data     = tomap(local.catalog_data_json)
  entitlement_data = tomap(local.entitlement_data_json)
  policy_data      = tomap(local.policy_data_json)

}
