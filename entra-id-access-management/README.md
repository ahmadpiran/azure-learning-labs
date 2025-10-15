# Entra ID Access Management
Learning Azure Entra ID through hands-on Terraform practice.

## Current Status: 🚧 In Progress - Step 2 - Variables
Refactored to use variables instead of hardcoded values.

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

## What's new in step 2
- Variables for domain and password
- Local blocks for user definitions
- More structured approach (ready to scale)

## Project Evolution
- ✅ Step 1: Single hardcoded user
- ✅ Step 2: Variables and better structure


## What works now
- Creates a single test user in Azure Entra ID
- Proves Terraform + Azure AD integration works

## Current state
This is a learning project. Right now It's intentionally simple. Check commit history to see evolution!