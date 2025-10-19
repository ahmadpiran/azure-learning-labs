# Define out application
locals {
  applications = {
    customer_portal = {
      display_name = "Runsy-CustomerPortal"
      description  = "Public-facing customer portal application"
      web_redirect_uris = [
        "https://portal.runsy.io/auth/callback",
        "https://localhost:3000/auth/callback" # For local development
      ]
      sign_in_audience = "AzureADMyOrg" # Single tenant
    }

    internal_api = {
      display_name = "Runsy-InternalAPI"
      description  = "Internal API backend services"
      web_redirect_uris = [
        "https://api.runsy.io/auth/callback"
      ]
      sign_in_audience = "AzureADMyOrg" # Single tenant
    }
    admin_dashboard = {
      display_name = "Runsy-AdminDashboard"
      description  = "Administrative dashboard for internal use"
      web_redirect_uris = [
        "https://admin.runsy.io/auth/callback",
        "https://localhost:3001/auth/callback" # For local development
      ]
      sign_in_audience = "AzureADMyOrg" # Single tenant
    }
  }
}

# Create application registrations
resource "azuread_application" "apps" {
  for_each = local.applications

  display_name     = each.value.display_name
  sign_in_audience = each.value.sign_in_audience

  # Web application configuration
  web {
    redirect_uris = each.value.web_redirect_uris

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true # Enable ID tokens for login
    }
  }

  # Required API permissions (Microsoft Graph)
  required_resource_access {
    # Microsoft Graph API
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    # User.Read - Read signed-in user's profile
    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214"
      type = "Scope" # Delegated permission
    }
  }
}

# Create service principals for applications
# These are needed for the apps to actually work in the tanant
resource "azuread_service_principal" "app_service_principals" {
  for_each = azuread_application.apps

  client_id = each.value.client_id

  # Use the same display name as the apps
  app_role_assignment_required = false # Users don't need explicit assignments yet

  tags = ["Runsy", "Terraform", "CustomerPortal"] 
}

