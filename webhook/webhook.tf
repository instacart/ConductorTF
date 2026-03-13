resource "conductorone_webhook" "new_webhook" {
  display_name = var.webhook_display_name
  url          = var.webhook_url
  description  = var.webhook_description
}
