data "azuread_client_config" "current" {}

# Locals for computed values
locals {
    test_users = {
        ahmad = {
            username = "ahmad.cloud"
            display_name = "Ahmad Cloud"
            department = "Engineering"
        }
    }
}

# Create the test user (just one for now)
resource "azuread_user" "test_user" {
  user_principal_name   = "${local.test_users.ahmad.username}@${var.tenant_domain}"
  display_name          = local.test_users.ahmad.display_name
  department = local.test_users.ahmad.department
  password              = var.user_password
  force_password_change = true
}

# Show us what created
output "user_id" {
  value = azuread_user.test_user.id
}

output "user_principal_name" {
  value = azuread_user.test_user.user_principal_name
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}