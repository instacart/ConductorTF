// Policies to be delegated through ConductorOne
// https://registry.terraform.io/providers/ConductorOne/conductorone/latest/docs/resources/policy


// Approver Configuration Options:
// 
// 1) User
// 2) Manager
// 3) App Owner
// 4) Role Owner
// 5) Okta Group 
// 

# module "policy" {
#
#     policy_type                         = "Declare which type of C1 policy this is. 'POLICY_TYPE_GRANT', 'POLICY_TYPE_REVOKE', or 'POLICY_TYPE_CERTIFY'"
#     policy_name                         = "Name of the Policy. A list of templates is available. See go/c1"
#     policy_description                  = "Description of the Policy. Ex. 'This policy requires review from someone within A,B,C Okta Groups before being granted.'"
#     allow_decision_reassignment         = "Allow decisions for this policy to be delegated. (true/false)"
#     require_approval_reason             = "Require documented business decision for approval of request. (true/false)"
#     approval_steps {
#       approver_type                        = "User, Manager, App Owner, Role Owner, or Okta Group" ***
#       approver_name                        = "Name of the approver. Ex. 'Team Security'
#       enable_fallback_users                = "If initial approvers are unavailable, call on list of fallback users. (true/false)"
#       fallback_user_ids                    = "Define user email addresses to be used in case of fallback."
#       allow_self_review                    = "Allow a user pre-defined as an approver for this policy to self-approve themselves when needed."
#       allow_step_reassignment              = "Allow decisions for this step of the policy to be delegated (true/false)" ***
#       require_decision_reassignment_reason = "Require a recorded business decision on why an approval workflow must be re-assigned. (true/false)" 
#       require_approval_reason              = "Require a recorded reason for approval. (true/false)"
#     }
#     


resource "conductorone_policy" "revoke_policy" {
  count                       = var.policy_type != "POLICY_TYPE_REVOKE" ? 0 : 1
  policy_type                 = var.policy_type
  display_name                = var.policy_name
  description                 = var.policy_description
  reassign_tasks_to_delegates = var.allow_decision_reassignment
  policy_steps = {
    revoke = local.common_steps
  }
}

resource "conductorone_policy" "certify_policy" {
  count                       = var.policy_type != "POLICY_TYPE_CERTIFY" ? 0 : 1
  policy_type                 = var.policy_type
  display_name                = var.policy_name
  description                 = var.policy_description
  reassign_tasks_to_delegates = var.allow_decision_reassignment
  policy_steps = {
    certify = local.common_steps
  }
  post_actions = [{
    certify_remediate_immediately = var.post_exec_immediate_deprovision
  }]
}

resource "conductorone_policy" "custom_request_policy" {
  count                       = var.policy_type == "POLICY_TYPE_GRANT" && local.has_expressions ? 1 : 0
  policy_type                 = var.policy_type
  display_name                = var.policy_name
  description                 = var.policy_description
  reassign_tasks_to_delegates = var.allow_decision_reassignment
  policy_steps                = local.policy_steps
  rules = flatten([
    for idx, step in local.expressions_with_indexes : [
      for expr in step.expressions : {
        condition  = expr
        policy_key = "override-${idx}"
      }
    ]
  ])
}

resource "conductorone_policy" "request_policy" {
  count                       = var.policy_type == "POLICY_TYPE_GRANT" && !local.has_expressions ? 1 : 0
  policy_type                 = var.policy_type
  display_name                = var.policy_name
  description                 = var.policy_description
  reassign_tasks_to_delegates = var.allow_decision_reassignment
  policy_steps = {
    grant = local.common_steps
  }
}
