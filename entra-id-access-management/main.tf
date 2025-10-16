data "azuread_client_config" "current" {}

# Define multiple users
locals {
  users = {
    ahmad_cloud = {
      username     = "ahmad.cloud"
      display_name = "Ahmad Cloud"
      department   = "Engineering"
      job_title    = "Senior Cloud Engineer"
      groups       = ["engineering", "operations"]
    }
    ilhan_ops = {
      username     = "ilhan.ops"
      display_name = "ilhan Operations"
      department   = "Operations"
      job_title    = "DevOps Engineer"
      groups       = ["operations"]
    }
    ayhan_finance = {
      username     = "ayhan.finance"
      display_name = "Ayhan Finance"
      department   = "Finance"
      job_title    = "Financial Analyst"
      groups       = ["finance"]
    }
    sara_contractor = {
      username     = "sara.contractor"
      display_name = "Sara Contractor"
      department   = "External"
      job_title    = "Contract Developer"
      groups       = ["contractors"]
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