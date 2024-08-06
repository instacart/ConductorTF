
output "debug_expressions_match_action" {
  value = [for step in var.approval_steps : step.expressions_match_action]
}

output "debug_approval_steps" {
  value = var.approval_steps
}

output "debug_expr_with_indexes" {
  value = local.expressions_with_indexes
}
