output "webhook_id" {
  description = "The ID of the created webhook"
  value       = conductorone_webhook.new_webhook.id
}

output "webhook_display_name" {
  description = "The display name of the webhook"
  value       = var.webhook_display_name
}

# Output for mapping display name to ID - useful for lookup operations
output "webhook_name_to_id" {
  description = "Map of webhook display name to ID"
  value = {
    (var.webhook_display_name) = conductorone_webhook.new_webhook.id
  }
}
