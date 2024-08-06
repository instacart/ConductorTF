variable "environment" {
  type = string
}

variable "policy_name" {
  type        = string
  description = "Name of the policy."
}

variable "policy_description" {
  type = string
}

variable "policy_type" {
  type        = string
  description = "Declare which type of C1 policy this is. 'POLICY_TYPE_GRANT', 'POLICY_TYPE_REVOKE', or 'POLICY_TYPE_CERTIFY'"

  validation {
    condition     = contains(["POLICY_TYPE_GRANT", "POLICY_TYPE_REVOKE", "POLICY_TYPE_CERTIFY"], var.policy_type)
    error_message = "Must be either \"POLICY_TYPE_GRANT\", \"POLICY_TYPE_REVOKE\", or \"POLICY_TYPE_CERTIFY\"."
  }
}

variable "allow_decision_reassignment" {
  type        = bool
  description = "Allow decisions for this policy to be delegated. (true/false)"
}

variable "fallback_user_ids" {
  type        = list(string)
  description = "Provide fallback/backup approver user IDs."
  default     = []
}

variable "require_decision_reassignment_reason" {
  type        = bool
  description = "Require documented business decision for this policy to be delegated. (true/false)"
  default     = false
}

variable "require_approval_reason" {
  type        = bool
  description = "Require documented business decision for approval of request."
  default     = false
}

variable "assign_to_reviewers" {
  type        = bool
  description = "Assign to reviewers (true), or declare an automatic approve/deny (false)."
  default     = true
}

variable "approval_steps" {
  type = list(object({
    approver_type                        = string
    approver_name                        = optional(string)
    enable_fallback_users                = optional(bool)
    user_ids                             = optional(list(string))
    fallback_user_ids                    = optional(list(string))
    allow_self_review                    = optional(bool)
    allow_decision_reassignment          = optional(bool)
    require_decision_reassignment_reason = optional(bool)
    require_approval_reason              = optional(bool)
    expressions                          = optional(list(string))
    expressions_match_action = optional(list(object({
      assignee_expressions = optional(list(string))
      schedule_name        = optional(string)
      action_type          = optional(string)
      approver_type        = optional(string)
      group_name           = optional(string)
      user_ids             = optional(list(string))
    })))
  }))
}

variable "post_exec_immediate_deprovision" {
  type        = bool
  default     = false
  description = "Should deprovision action be taken immediately following completion of workflow (true/false)"
}

variable "conductorone_directory_app_id" {
  type        = string
  description = "The unique C1 directory app ID, this is typically the app ID assigned to Okta."
}

variable "opsgenie_app_id" {
  type        = string
  description = "The unique C1 app ID for OpsGenie."
}

variable "conductorone_service_account_id" {
  type        = string
  description = "The unique C1 user account ID used to integrate ConductorOne and Okta."
}

variable "trigger" {
  type        = string
  description = "This is an md5 hash used to trigger Terraform when changes are made to YAML files."
}
