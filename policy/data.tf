data "conductorone_user" "user_lookup" {
  for_each = toset(flatten([for step in var.approval_steps : compact(step.user_ids != null ? step.user_ids : [])]))
  email    = each.key
}

data "conductorone_user" "fallback_user_lookup" {
  for_each = toset(flatten([for step in var.approval_steps : compact(step.fallback_user_ids != null ? step.fallback_user_ids : [])]))
  email    = each.key
}

data "conductorone_user" "expression_user_lookup" {
  for_each = local.expression_user_ids
  email    = each.key
}
