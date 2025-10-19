# Entra ID Access Management Lab

Learning Azure Entra ID through hands-on Terraform practice.

## Current Status: Step 6 - App Role Assignments ✅

Implemented complete access control with app roles and group-based assignments.

## Access Control Matrix

| Group | Customer Portal | Internal API | Admin Dashboard |
|-------|----------------|--------------|-----------------|
| **Engineering** | Admin | Full Access | Admin |
| **Operations** | - | Full Access | Admin |
| **Finance** | Read Only | - | Viewer |
| **Contractors** | - | Limited | - |

## Current Architecture
```
Users → Groups → App Roles → Applications

Example Flow:
John (Engineering) 
  → Engineering-FullAccess group 
  → CustomerPortal.Admin role 
  → TechFlow-CustomerPortal app
  → Full administrative access
```

## What We Built in Step 6

### App Roles
Each application defines permission levels:
- **Customer Portal**: Admin, User, ReadOnly
- **Internal API**: FullAccess, Limited
- **Admin Dashboard**: Admin, Viewer

### Role Assignments
Groups are assigned to applications with specific roles:
- Centrally managed in `app_role_assignments.tf`
- Easy to modify and audit
- Automatically enforced by Entra ID

### Security Model
- Users inherit permissions from their groups
- Applications check roles in authentication tokens
- No direct user-to-app assignments (scales better)

## Key Concepts

**App Role**: Permission level within an application (like Admin, User, Viewer)

**App Role Assignment**: Granting a group a specific role in an application

**Service Principal**: Required for role assignments (the "instance" of the app)

## File Structure
```
├── main.tf                  # User definitions
├── groups.tf                # Security groups and memberships
├── applications.tf          # App registrations with roles
├── app_role_assignments.tf  # Access control (NEW!)
├── variables.tf             # Input variables
├── outputs.tf               # Output values
└── terraform.tfvars         # Your configuration
```

## Viewing in Azure Portal

**See assigned roles:**
1. **Microsoft Entra ID** → **Enterprise applications**
2. Click any app → **Users and groups**
3. See which groups have which roles

**See user's access:**
1. **Microsoft Entra ID** → **Users**
2. Click a user → **Applications**
3. See all apps they can access

## Project Evolution
- ✅ Step 1: Single hardcoded user
- ✅ Step 2: Variables and better structure
- ✅ Step 3: Multiple users with for_each
- ✅ Step 4: Security groups (production pattern)
- ✅ Step 5: Application registrations
- ✅ Step 6: App role assignments (access control)