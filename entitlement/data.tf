data "conductorone_app" "mirror_app" {
  display_name = var.mirrored_application_name
}

data "conductorone_user" "svc_user" {
  email = var.conductorone_service_account_email
}
