// Applications to be managed through ConductorOne
// https://registry.terraform.io/providers/ConductorOne/conductorone/latest/docs/resources/app

# module "application" {
#
#     source             = "./modules/application"
#     app_display_name   = Display name of the application
#     app_description    = Description of application provided to users
#     app_owner_email    = E-mail address of app owner in C1. This may be used in approval workflows.
#     mirrored_app       = Whether this is a mirrored app for UI purposes. (T/F)
#
# }

resource "conductorone_app" "new_app" {
  display_name = var.app_display_name
  description  = var.app_description
}

resource "conductorone_app_owner" "new_app_owner" {
  app_id = conductorone_app.new_app.id
  user_ids = [
    data.conductorone_user.app_owner.id
  ]
}

data "conductorone_user" "app_owner" {
  email = var.app_owner_email
}

# if this is generating a mirrored app, must have mirrored resource type
resource "conductorone_app_resource_type" "mirrored_app_resource_type" {
  count         = var.mirrored_app ? 1 : 0
  display_name  = var.resource_type_name
  app_id        = conductorone_app.new_app.id
  resource_type = "GROUP"
}
