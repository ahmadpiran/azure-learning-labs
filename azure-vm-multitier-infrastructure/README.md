# Azure VM Multi-Tier Infrastructure

Learning project to build production-ready VM infrastructure.

## Current Phase
Phase 1 - Step 3: VM automation with cloud-init ✅

## What's Deployed
- 1 Ubuntu 24.04 VM (Standard_B1s)
- Nginx web server (auto-installed via cloud-init)
- Custom web page served on port 80
- SSH access on port 22
- Basic networking (VNet, Subnet, Public IP)

## Features
- ✅ Automated VM configuration (no manual setup)
- ✅ Web server installed and running on first boot
- ✅ Custom HTML page demonstrating cloud-init
- ✅ All configuration is code (reproducible)

## Access

### SSH
```bash
ssh -i ~/.ssh/azure_vm_key azureuser@[VM_PUBLIC_IP]
```

### Web Browser
```
http://[VM_PUBLIC_IP]
```

## Cloud-Init Script
Located in: `scripts/cloud-init/web-server-init.yml`

Installs:
- Nginx web server
- Git
- htop (process viewer)
- net-tools
- curl

## Quick Commands

### Deploy
```bash
cd terraform
terraform apply
```

### Check Outputs
```bash
terraform output
```

### Destroy
```bash
terraform destroy
```

## What I Learned
- Cloud-init for VM bootstrapping
- Azure custom_data parameter
- NSG rules for multiple ports
- Terraform filebase64() function
- The VM replacement process
- How to verify cloud-init completion

## Files Structure
```
.
├── README.md
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf
└── scripts/
    └── cloud-init/
        └── web-server-init.yml
```

## Notes
- Cloud-init runs on first boot only
- Changes to custom_data require VM replacement
- Check cloud-init status: `cloud-init status`
- Logs: `/var/log/cloud-init-output.log`