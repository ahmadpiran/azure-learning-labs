# Phase 1 - Deployment Guide

## Prerequisites

### Required Software
- Terraform >= 1.0
- Azure CLI >= 2.50
- Git
- SSH client

### Azure Requirements
- Active Azure subscription
- Permissions to create resources
- Resource quota for 1 VM

## Step-by-Step Deployment

### 1. Clone Repository
```bash
git clone git@github.com:ahmadpiran/azure-learning-labs.git
cd azure-learning-labs/azure-vm-multitier-infrastructure
```

### 2. Authenticate to Azure
```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_NAME"
az account show
```

### 3. Generate SSH Key
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_vm_key
# Press Enter for no passphrase
```

### 4. Initialize Terraform
```bash
cd terraform
terraform init
```

### 5. Review Configuration
```bash
# Check variables
cat variables.tf

# Review what will be created
terraform plan -out main.tfplan
```

### 6. Deploy Infrastructure
```bash
terraform apply main.tfplan
# Wait 3-5 minutes for completion
```

### 7. Get Connection Info
```bash
# View all outputs
terraform output

# Get SSH command
terraform output -raw ssh_command

# Get web URL
terraform output -raw web_url
```

### 8. Verify Deployment

#### Test SSH Access
```bash
ssh -i ~/.ssh/azure_vm_key azureuser@<PUBLIC_IP>

# Inside VM, check:
cloud-init status              # Should show "done"
df -h | grep /mnt/data        # Should show data disk
systemctl status nginx         # Should show "active"
ls -la /mnt/data              # Should show app directory

exit
```

#### Test Web Access
```bash
# From your machine
curl http://<PUBLIC_IP>

# Or open in browser:
# http://<PUBLIC_IP>
```

### 9. Explore the VM
```bash
ssh -i ~/.ssh/azure_vm_key azureuser@<PUBLIC_IP>

# View installed packages
dpkg -l | grep nginx
dpkg -l | grep git

# Check disk layout
lsblk
df -h

# View cloud-init logs
sudo cat /var/log/cloud-init-output.log

# Check cloud-init completion
cat /var/log/cloud-init-completion.log

# View web page source
cat /var/www/html/index.html

exit
```

## Teardown

### Destroy All Resources
```bash
cd terraform
terraform -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan
```

**⚠️ WARNING**: This deletes EVERYTHING, including the data disk and any data on it!

### Verify Cleanup
```bash
# Check resource group is gone
az group show --name rg-vminfra-lab-dev
# Should show: "ResourceGroupNotFound"
```

## Updating the Infrastructure


### Increasing Disk Size
```bash
# Edit variables.tf, increase data_disk_size_gb
terraform plan -out main.tfplan
terraform apply main.tfplan

# Then SSH into VM and grow the filesystem:
ssh -i ~/.ssh/azure_vm_key azureuser@<IP>
sudo parted /dev/sdc resizepart 1 100%
# rescan the disk
echo 1 | sudo tee /sys/class/block/sda/device/rescan

sudo umount /dev/sdc1

sudo parted /dev/sdc
(parted) print
(parted) resizepart 1 100%
(parted) quit

sudo e2fsck -f /dev/sdc1
sudo resize2fs /dev/sdc1
df -h | grep /mnt/data  # Verify new size
```

## Backup Strategy (Manual for now)

### Backup Data Disk
```bash
# Create snapshot
az snapshot create \
  --resource-group rg-vm-lab-dev \
  --name snapshot-data-$(date +%Y%m%d) \
  --source disk-data-vm-lab-001
```

### Restore from Snapshot
```bash
# Create disk from snapshot
az disk create \
  --resource-group rg-vm-lab-dev \
  --name disk-restored \
  --source snapshot-data-YYYYMMDD

# Attach to VM (would need to update Terraform)
```

## Security Notes

- ⚠️ SSH is open to the internet (port 22 from *)
- ⚠️ HTTP is open to the internet (port 80 from *)
- ✅ Password authentication is disabled
- ✅ SSH key authentication required


## Support

- Review: `docs/lessons-learned.md`
- Architecture: `docs/architecture-diagrams/phase1-architecture.md`
- Check git history: `git log --oneline`