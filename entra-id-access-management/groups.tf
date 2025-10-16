# Define our security groups
locals {
  groups = {
    engineering = {
      display_name = "Engineering-FullAccess"
      description  = "Engineering team with full access to development resources"
    }
    operations = {
      display_name = "Operations-InfraAceess"
      description  = "Operations team with infrastructure management access"
    }
    finance = {
      display_name = "Finance-ReadOnly"
      description  = "Finance team with read-only access to financial data"
    }
    contractors = {
      display_name = "Contractors-Limited"
      description  = "External contractors with limited temporary access"
    }
  }

  /*
    Flatten user-group relationships into individual memberships
    This creates a map like:
    {
    ahmad_cloud-engineering = { user_key = "ahmad_cloud", group_key = "engineering" }
    ahmad_cloud-operations  = { user_key = "ahmad_cloud", group_key = "operations" }
    ilhan_ops-operations    = { user_key = "ilhan_ops", group_key = "operations" }
    }
  */
  user_group_memberships = merge([
    for user_key, user in local.users : {
      for group_key in user.groups :
      "${user_key}-${group_key}" => {
        user_key  = user_key
        group_key = group_key
      }
    }
  ]...)
}

# Create the security groups
resource "azuread_group" "department_groups" {
  for_each = local.groups

  display_name     = each.value.display_name
  description      = each.value.description
  security_enabled = true
}

# Create individual membership relationships
# Each membership is its own resource - can be added/removed independently
resource "azuread_group_member" "memberships" {
  for_each = local.user_group_memberships

  group_object_id  = azuread_group.department_groups[each.value.group_key].object_id
  member_object_id = azuread_user.users[each.value.user_key].object_id
}



