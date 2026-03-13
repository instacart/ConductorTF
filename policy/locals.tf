locals {
  entitlement_data = var.all_entitlements
  webhook_data     = var.all_webhooks

  expressions_collected = [for step in var.approval_steps : step if step.approver_type == "Expression"]
  has_expressions       = true ? (length(local.expressions_collected) > 0) : false

  expressions_filtered         = flatten(local.expressions_collected)
  expressions_filtered_indexes = range(length(local.expressions_filtered))
  expressions_with_indexes     = zipmap(local.expressions_filtered_indexes, local.expressions_filtered)

  expression_user_ids = toset(flatten([
    for step in var.approval_steps : [
      for expression in(step.expressions_match_action != null ? step.expressions_match_action : []) :
      expression.user_ids if expression.approver_type == "User"
    ]
  ]))

  common_steps = {
    steps = flatten([
      [for step in var.approval_steps : step.approver_type == "Account Owner" ? [{
        approval = {
          allow_reassignment          = step.allow_decision_reassignment
          require_reassignment_reason = step.require_decision_reassignment_reason
          require_approval_reason     = step.require_approval_reason
          reassign_tasks_to_delegates = step.allow_decision_reassignment
          self_approval               = {}
        }
        }] : []
      ],
      [for step in var.approval_steps : step.approver_type == "Manager" ? [{
        approval = {
          allow_reassignment          = step.allow_decision_reassignment
          require_reassignment_reason = step.require_decision_reassignment_reason
          require_approval_reason     = step.require_approval_reason
          reassign_tasks_to_delegates = step.allow_decision_reassignment
          manager_approval            = {}
        }
        }] : []
      ],
      [for step in var.approval_steps : step.approver_type == "Opsgenie On-Call" ? [{
        approval = {
          allow_reassignment          = step.allow_decision_reassignment
          require_reassignment_reason = step.require_decision_reassignment_reason
          require_approval_reason     = step.require_approval_reason
          expression_approval = {
            "expressions" : [format("%s '%s', '%s')", "c1.user.v1.HasEntitlement(subject,", var.opsgenie_app_id, lookup(var.all_schedules, format("%s %s", step.approver_name, "schedule on-call")))]
          }
        }
        }] : []
      ],
      [for step in var.approval_steps : step.approver_type == "Okta Group" ? [{
        approval = {
          allow_reassignment          = step.allow_decision_reassignment
          require_reassignment_reason = step.require_decision_reassignment_reason
          require_approval_reason     = step.require_approval_reason
          app_group_approval = {
            allow_self_approval = step.allow_self_review
            app_group_id        = lookup(local.entitlement_data, format("%s %s", step.approver_name, "Group Member"))
            app_id              = var.conductorone_directory_app_id
            fallback            = step.enable_fallback_users
            fallback_user_ids   = step.enable_fallback_users ? [for user_id in step.fallback_user_ids : data.conductorone_user.fallback_user_lookup[user_id].id] : [var.conductorone_service_account_id]
        } }
        }] : []
      ],
      [for step in var.approval_steps : step.approver_type == "Webhook" ? [{
        approval = {
          allow_reassignment          = step.allow_decision_reassignment
          require_reassignment_reason = step.require_decision_reassignment_reason
          require_approval_reason     = step.require_approval_reason
          webhook_approval = {
            webhook_id = lookup(local.webhook_data, step.webhook_name)
        } }
        }] : []
      ],
      [for step in var.approval_steps : step.approver_type == "User" ? [{
        approval = {
          allow_reassignment          = step.allow_decision_reassignment
          require_reassignment_reason = step.require_decision_reassignment_reason
          require_approval_reason     = step.require_approval_reason
          reassign_tasks_to_delegates = step.allow_decision_reassignment
          user_approval = {
            user_ids            = length(step.user_ids) > 0 ? [for user_id in step.user_ids : try(data.conductorone_user.user_lookup[user_id].id, "fallback_id")] : [var.conductorone_service_account_id]
            allow_self_approval = step.allow_self_review
            fallback            = step.enable_fallback_users
            fallback_user_ids   = step.enable_fallback_users ? [for user_id in step.fallback_user_ids : data.conductorone_user.fallback_user_lookup[user_id].id] : [var.conductorone_service_account_id]
        } }
        }] : []
      ],
    ])
  }

  override_steps = {
    for idx, expr_parent_step in local.expressions_with_indexes : "override-${idx}" => {
      steps = flatten([
        for expression in(expr_parent_step.expressions_match_action != null ? expr_parent_step.expressions_match_action : []) : [
          expression.approver_type == "Auto-Approve" ? {
            "accept" = {}
            } : expression.approver_type == "Auto-Deny" ? {
            "reject" = {}
            } : expression.approver_type == "Manager" ? {
            "approval" = {
              "manager_approval" = {}
            }
            } : expression.approver_type == "Assignee Expression" ? {
            "approval" = {
              "expression_approval" = {
                "expressions" : expression.assignee_expressions
              }
            }
            } : expression.approver_type == "Opsgenie On-Call" ? {
            "approval" = {
              "expression_approval" = {
                "expressions" : [format("%s '%s', '%s')", "c1.user.v1.HasEntitlement(subject,", var.opsgenie_app_id, lookup(var.all_schedules, format("%s %s", expression.schedule_name, "schedule on-call")))]
              }
            }
            } : expression.approver_type == "Okta Group" ? {
            "approval" = {
              "app_group_approval" = {
                "app_group_id" = lookup(local.entitlement_data, format("%s %s", expression.group_name, "Group Member")),
                "app_id"       = var.conductorone_directory_app_id
              }
            }
            } : expression.approver_type == "User" ? {
            "approval" = {
              "user_approval" = {
                "user_ids" = [for user_id in expression.user_ids : data.conductorone_user.expression_user_lookup[user_id].id]
              }
            }
          } : { "approval" = {} }
        ]
      ])
    }
  }

  policy_steps = merge(
    { grant = local.common_steps },
    local.override_steps
  )
}
