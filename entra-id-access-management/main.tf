data "azuread_client_config" "current" {}

# Create a single test user
resource "azuread_user" "test_user" {
  user_principal_name   = "ahmad.cloud@ahmadpiranoutlook.onmicrosoft.com"
  display_name          = "Ahmad Cloud"
  password              = "ChangeMe123!@#"
  force_password_change = true
}

# Show us what created
output "user_id" {
  value = azuread_user.test_user.id
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}