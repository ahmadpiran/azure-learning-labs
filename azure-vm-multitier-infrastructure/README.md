# Azure VM Multi-Tier Infrastructure

Learning project to build production-ready VM infrastructure.

## 🎯 Project Goals

- Learn Azure VM infrastructure from first principles
- Master Terraform for infrastructure as code
- Understand production-ready architecture patterns
- Build incrementally (working code at every step)
- Document everything for future reference

## 📊 Current Status

**Phase 1: COMPLETED ✅**

Single-VM infrastructure with automated configuration, persistent storage, and web server.

## 🏗️ What's Deployed (Phase 1)
```
├── Resource Group (rg-vminfra-lab-dev)
├── Virtual Network (10.0.0.0/16)
│   └── Subnet (10.0.1.0/24)
├── Network Security Group
│   ├── SSH Rule (port 22)
│   └── HTTP Rule (port 80)
├── Public IP (Static)
├── Network Interface
├── Virtual Machine (Ubuntu 24.04, Standard_B1s)
│   ├── OS Disk (30 GB)
│   └── Data Disk (32 GB, mounted at /mnt/data)
└── Cloud-Init Automation
    ├── Nginx web server
    ├── Development tools
    └── Automated disk setup
```

## 🚀 Quick Start

### Prerequisites
- Azure subscription
- Terraform >= 1.0
- Azure CLI >= 2.50
- SSH client

### Deploy
```bash
# Clone and navigate
git clone 
cd azure-learning-labs/azure-vm-multitier-infrastructure

# Authenticate to Azure
az login

# Generate SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_vm_key

# Deploy infrastructure
cd terraform
terraform init
terraform plan main.tfplan
terraform apply main.tfplan

# Get connection info
terraform output
```

### Access
```bash
# SSH
ssh -i ~/.ssh/azure_vm_key azureuser@$(terraform output -raw public_ip_address)

# Web (in browser)
# http://[public-ip]
```

### Destroy
```bash
terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan
```

