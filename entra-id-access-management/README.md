# Entra ID Access Management Lab

Learning Azure Entra ID through hands-on Terraform practice.

## Current Status: Step 5 - Application Registrations ✅

Created application registrations for Runsy's microservices with proper authentication configuration. (Runsy is a fictios SaaS)

## Current Architecture
```
Applications:
├── Runsy-CustomerPortal   (Web app, OAuth 2.0)
├── Runsy-InternalAPI      (Backend services)
└── Runsy-AdminDashboard   (Admin portal)

Users & Groups:
├── ahmad.cloud       → [Engineering-FullAccess, Operations-InfraAccess]
├── ilhan.ops         → [Operations-InfraAccess]
├── ayhan.finance     → [Finance-ReadOnly]
└── sara.contractor   → [Contractors-Limited]
```

## What I Built in Step 5

### Application Registrations
Each app has:
- **Client ID**: Unique identifier for authentication
- **Redirect URIs**: Where users return after login
- **API Permissions**: Microsoft Graph User.Read
- **Service Principal**: Runtime instance in the tenant

### Key Concepts
- **App Registration**: The app definition/template
- **Service Principal**: The app instance in your tenant
- **Client ID**: What your application code uses to authenticate

## Viewing in Azure Portal

1. Go to **Microsoft Entra ID** → **App registrations**
2. Click on any app to see its configuration
3. Check **Authentication** for redirect URIs
4. Check **API permissions** for granted permissions

## File Structure
```
├── main.tf           # User definitions
├── groups.tf         # Security groups and memberships
├── applications.tf   # App registrations (NEW!)
├── variables.tf      # Input variables
├── outputs.tf        # Output values
└── terraform.tfvars  # Your configuration
```

## Project Evolution
- ✅ Step 1: Single hardcoded user
- ✅ Step 2: Variables and better structure
- ✅ Step 3: Multiple users with for_each
- ✅ Step 4: Security groups (production pattern)
- ✅ Step 5: Application registrations