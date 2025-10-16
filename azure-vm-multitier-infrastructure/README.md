# Azure VM Multi-Tier Infrastructure

Learning project to build production-ready VM infrastructure.

## Current Phase
Phase 1 - Step 2: First working VM deployed ✅

## What's Deployed
- 1 Ubuntu 24.04 VM (Standard_B1s)
- Public IP for SSH access
- Basic networking (VNet, Subnet)
- NSG allowing SSH from anywhere (temporary)

## Quick Commands

### Deploy
```bash
cd terraform
terraform plan
terraform apply
```

### Connect
```bash
ssh -i ~/.ssh/azure_vm_key azureuser@[YOUR_PUBLIC_IP]
```

### Destroy
```bash
terraform destroy
```

## Notes
- SSH key: `~/.ssh/azure_vm_key`
- Started: 10/16/2025
- First successful deployment: 10/17/2025