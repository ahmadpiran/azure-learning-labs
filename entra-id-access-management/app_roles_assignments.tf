# Define which groups get which roles in which apps
locals {
  # Structure: group_key -> app_key -> role_key
  group_app_role_assignments = {
    engineering = {
      # Engineering gets full access to everything
      customer_portal = "admin"
      internal_api    = "full_access"
      admin_dashboard = "admin"
    }
    # Operations gets admin dashboard and API access
    operations = {
      admin_dashboard = "admin"
      internal_api    = "full_access"
    }
    # Finance gets read-only access to customer portal
    finance = {
      customer_portal = "read_only"
      admin_dashboard = "viewer"
    }
    # Contractors get limited API only access
    contractors = {
      internal_api = "limited"
    }
  }

  # Flatten the structure for Terraform resources
  # Result: { "engineering-customer_portal" => { group_key, app_key, role_key }, ... }
  flattened_assignments = merge([
    for group_key, apps in local.group_app_role_assignments : {
      for app_key, role_key in apps :
      "${group_key}-${app_key}" => {
        group_key = group_key
        app_key   = app_key
        role_key  = role_key
      }
    }
  ]...)
}

# Assign app roles to groups
resource "azuread_app_role_assignment" "group_assignments" {
  for_each = local.flattened_assignments

  # The group recieving the role
  principal_object_id = azuread_group.department_groups[each.value.group_key].object_id

  # The app's service principal
  resource_object_id = azuread_service_principal.app_service_principals[each.value.app_key].object_id

  # The specific role ID from the app
  app_role_id = [
    for role in azuread_application.apps[each.value.app_key].app_role :
    role.id if role.value == local.applications[each.value.app_key].app_roles[each.value.role_key].value
  ][0]
}