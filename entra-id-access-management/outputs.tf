# User outputs
output "created_users" {
  description = "Map of all created users"
  value = {
    for key, user in azuread_user.users : key => {
      id                  = user.id
      user_principal_name = user.user_principal_name
      display_name        = user.display_name
      department          = user.department
      assigned_groups     = local.users[key].groups
    }
  }
}

# Group outputs
output "created_groups" {
  description = "Map of all created security groups"
  value = {
    for key, group in azuread_group.department_groups : key => {
      id           = group.id
      display_name = group.display_name
      description  = group.description
    }
  }
}

# Application outputs
output "created_applications" {
  description = "Map of all created application registrations"
  value = {
    for key, app in azuread_application.apps : key => {
      application_id = app.client_id # This is the client ID
      object_id      = app.object_id
      display_name   = app.display_name
    }
  }
}

# Service Principal outputs
output "service_principals" {
  description = "Service Principals for applications"
  value = {
    for key, sp in azuread_service_principal.app_service_principals : key => {
      id           = sp.id
      object_id    = sp.object_id
      display_name = sp.display_name
    }
  }
}

# Membership details
output "group_memberships" {
  description = "Users assigned to each group"
  value = {
    for group_key, group in azuread_group.department_groups : group.display_name => [
      for user_key, user in local.users : user.display_name
      if contains(user.groups, group_key)
    ]
  }
}

# Individual membership resources (for debugging)
output "membership_resources" {
  description = "Individual membership resource IDs"
  value = {
    for key, membership in local.user_group_memberships : key => {
      user  = local.users[membership.user_key].display_name
      group = local.groups[membership.group_key].display_name
    }
  }
}

# Summary
output "summary" {
  description = "Quick summary of resources"
  value = {
    total_users       = length(azuread_user.users)
    total_groups      = length(azuread_group.department_groups)
    total_memberships = length(azuread_group_member.memberships)
    tenant_id         = data.azuread_client_config.current.tenant_id
  }
}