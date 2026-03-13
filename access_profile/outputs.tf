output "access_profile_id" {
  description = "The ID of the created access profile"
  value       = var.is_bundle == true ? try(conductorone_access_profile.access_profile_bundle[0].id, null) : try(conductorone_access_profile.access_profile[0].id, null)
}

output "access_profile_display_name" {
  description = "The display name of the access profile"
  value       = var.access_profile_display_name
}

# Output for mapping display name to ID - useful for lookup operations
output "access_profile_name_to_id" {
  description = "Map of access profile display name to ID"
  value = var.is_bundle == true ? (
    length(conductorone_access_profile.access_profile_bundle) > 0 ? {
      (var.access_profile_display_name) = conductorone_access_profile.access_profile_bundle[0].id
    } : {}
    ) : (
    length(conductorone_access_profile.access_profile) > 0 ? {
      (var.access_profile_display_name) = conductorone_access_profile.access_profile[0].id
    } : {}
  )
}
