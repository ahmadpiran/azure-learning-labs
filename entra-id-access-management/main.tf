data "azuread_client_config" "current" {}

# Define multiple users
locals {
  users = {
    ahmad_cloud = {
      username     = "ahmad.cloud"
      display_name = "Ahmad Cloud"
      department   = "Engineering"
      job_title    = "Senior Cloud Engineer"
    }
    ilhan_ops = {
      username     = "ilhan.ops"
      display_name = "ilhan Operations"
      department   = "Operations"
      job_title    = "DevOps Engineer"
    }
    ayhan_finance = {
      username     = "ayhan.finance"
      display_name = "Ayhan Finance"
      department   = "Finance"
      job_title    = "Financial Analyst"
    }
    sara_contractor = {
      username     = "sara.contractor"
      display_name = "Sara Contractor"
      department   = "External"
      job_title    = "Contract Developer"
    }
  }
}

# Create all users with for_each
resource "azuread_user" "users" {
  for_each = local.users

  user_principal_name   = "${each.value.username}@${var.tenant_domain}"
  display_name          = each.value.display_name
  department            = each.value.department
  job_title             = each.value.job_title
  password              = var.user_password
  force_password_change = true
}

# Show all created users
output "created_users" {
  description = "Map all created users"
  value = {
    for key, user in azuread_user.users : key => {
      id                  = user.id
      user_principal_name = user.user_principal_name
      display_name        = user.display_name
      department          = user.department
    }
  }
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

# Quick summary
output "user_count" {
  description = "Total number of users created"
  value       = length(azuread_user.users)
}