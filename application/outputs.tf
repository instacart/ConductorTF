output "app_id" {
  description = "The ID of the created application"
  value       = conductorone_app.new_app.id
}

output "app_display_name" {
  description = "The display name of the application"
  value       = var.app_display_name
}
