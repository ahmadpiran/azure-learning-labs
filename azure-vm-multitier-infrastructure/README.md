# Azure VM Multi-Tier Infrastructure

Learning project to build production-ready VM infrastructure.

## Current Phase
Phase 1 - Step 4: Data disk for persistent storage ✅

## What's Deployed
- 1 Ubuntu 24.04 VM (Standard_B1s)
- 1 OS disk (30 GB, Standard_LRS)
- **1 Data disk (32 GB, Standard_LRS)**
- Nginx web server
- Automated disk formatting and mounting
- Custom web page

## Storage Architecture
- **OS Disk** (`/`): System files, applications
- **Temp Disk** (`/mnt`): Ephemeral storage (lost on VM restart)
- **Data Disk** (`/mnt/data`): Persistent application data

## Data Disk Details
- Size: 32 GB
- Type: Standard_LRS (HDD)
- Mount point: `/mnt/data`
- Filesystem: ext4
- Auto-mount: Yes (via /etc/fstab)
- Owned by: azureuser

## Access

### SSH
```bash
ssh -i ~/.ssh/azure_vm_key azureuser@[YOUR_PUBLIC_IP]
```

### Web Browser
```
http://[YOUR_PUBLIC_IP]
```

### Data Disk Location (inside VM)
```bash
cd /mnt/data
ls -la
```

## Quick Commands

### Deploy
```bash
cd terraform
terraform apply
```

### Check Disk Inside VM
```bash
ssh -i ~/.ssh/azure_vm_key azureuser@[IP]
df -h | grep /mnt/data
lsblk
exit
```

### Destroy
```bash
terraform destroy
# WARNING: This deletes the data disk and all data on it!
```

## Cost
- VM: ~$8-10/month
- Data disk (32 GB Standard_LRS): ~$1.50/month
- **Total: ~$10-12/month**

## What I Learned
- Difference between OS disk and data disk
- Azure managed disks
- Disk attachment with LUN
- Automatic disk formatting with cloud-init
- Partitioning with parted
- Adding entries to /etc/fstab
- Disk persistence across VM restarts
- Block device naming in Linux (/dev/sdc)

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

## Important Notes
- Data disk survives VM stop/start
- Data disk does NOT survive `terraform destroy`
- Temp disk (`/mnt` on Azure VMs) is ephemeral
- Always use data disks for application data
- Backups should target data disks, not OS disks
