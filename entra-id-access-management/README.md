# Entra ID Access Management
Learning Azure Entra ID through hands-on Terraform practice.

## Current Status(In progress): Step 3 - Multiple Users ✅

Using `for_each` to create multiple users from a single resource definition.

## Prerequisites
- Azure subscription
- Azure CLI(`az login`)
- Terraform >= 1.13

## Usage
1. Find your tenant domain:
```bash
az rest --method GET --url https://graph.microsoft.com/v1.0/domains
```

2. Create `terraform.tfvars`:
```hcl
tenant_domain = "yourcompany.onmicrosoft.com"
user_password = "YourSecurePassword!@#"
```

3. Run:
```bash
terraform init
terraform plan
terraform apply
```

## Current Features
- ✅ Creates multiple users from a map definition
- ✅ Each user has department and job title
- ✅ Easy to add/remove users without affecting others
- ✅ Structured outputs showing all created users

## Adding More Users

Just add to the `users` map in `main.tf`:
```hcl
locals {
  users = {
    new_user = {
      username     = "new.user"
      display_name = "New User"
      department   = "Sales"
      job_title    = "Sales Rep"
    }
    # ... existing users ...
  }
}
```

Run `terraform apply` - only the new user is created!

## Project Evolution
- ✅ Step 1: Single hardcoded user
- ✅ Step 2: Variables and better structure
- ✅ Step 3: Multiple users with for_each


## What works now
- Creates a single test user in Azure Entra ID
- Proves Terraform + Azure AD integration works

## Current state
This is a learning project. Right now It's intentionally simple. Check commit history to see evolution!