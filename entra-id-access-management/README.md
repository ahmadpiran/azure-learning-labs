# Entra ID Access Management
Learning Azure Entra ID through hands-on Terraform practice.

## Current Status(In progress): Step 4 - Security Groups ✅

Users are organized into department-based security groups with separate membership resources.

This project uses `azuread_group_member` resources instead of the `members` attribute because:

- **Granular control**: Each membership is independently managed
- **Hybrid management**: Supports both Terraform and manual changes
- **Reduced blast radius**: Changes to one member don't affect others
- **Enterprise ready**: Pattern used in production environments


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
- ✅ Creates multiple users and security groups from a map definition
- ✅ Each user has department and job title and group assignment
- ✅ Easy to add/remove users without affecting others
- ✅ Easy to add/remove users to groups
- ✅ Structured outputs showing all created users and groups and memnerships

## Current Architecture
```
Users:
├── ahmad.cloud       → [Engineering-FullAccess, Operations-InfraAccess]
├── ilhan.ops         → [Operations-InfraAccess]
├── ayhan.finance     → [Finance-ReadOnly]
└── sara.contractor   → [Contractors-Limited]

Total: 4 users, 4 groups, 5 memberships
```

## Adding Users with Multiple Groups
```hcl
new_user = {
  username     = "new.user"
  display_name = "New User"
  department   = "Engineering"
  job_title    = "Developer"
  groups       = ["engineering", "operations"]  # Multiple groups!
}
```

## Project Evolution
- ✅ Step 1: Single hardcoded user
- ✅ Step 2: Variables and better structure
- ✅ Step 3: Multiple users with for_each
- ✅ Step 4: Security groups


## Current state
This is a learning project. Right now It's intentionally simple. Check commit history to see evolution!