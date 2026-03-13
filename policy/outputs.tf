output "policy_id" {
  description = "The ID of the created policy"
  value = (
    length(conductorone_policy.revoke_policy) > 0 ? conductorone_policy.revoke_policy[0].id :
    length(conductorone_policy.certify_policy) > 0 ? conductorone_policy.certify_policy[0].id :
    length(conductorone_policy.custom_request_policy) > 0 ? conductorone_policy.custom_request_policy[0].id :
    length(conductorone_policy.request_policy) > 0 ? conductorone_policy.request_policy[0].id :
    null
  )
}

output "policy_name" {
  description = "The display name of the created policy"
  value = (
    length(conductorone_policy.revoke_policy) > 0 ? conductorone_policy.revoke_policy[0].display_name :
    length(conductorone_policy.certify_policy) > 0 ? conductorone_policy.certify_policy[0].display_name :
    length(conductorone_policy.custom_request_policy) > 0 ? conductorone_policy.custom_request_policy[0].display_name :
    length(conductorone_policy.request_policy) > 0 ? conductorone_policy.request_policy[0].display_name :
    null
  )
}

output "policy_type" {
  description = "The type of the created policy"
  value       = var.policy_type
}

output "policy_description" {
  description = "The description of the created policy"
  value       = var.policy_description
}
