# Phase 1 - Architecture Overview

## Infrastructure Diagram

[Phase1-Architecture](./architecture-diagrams/phase1-architecture.png)

## Component Details

### Networking
- **Virtual Network**: Isolated network space in Azure
- **Subnet**: Segment within VNet for resource placement
- **Public IP**: Static IP for internet access
- **Network Interface**: Virtual NIC connecting VM to subnet
- **NSG**: Firewall controlling Inbound/Outbound traffic

### Compute
- **VM Size**: B-series burstable, cost-effective for dev/test
- **OS Disk**: Managed by Azure, contains OS and system files
- **Temp Disk**: Ephemeral, provided by Azure, not persistent
- **Data Disk**: Persistent storage for application data

### Security
- **SSH Key Authentication**: Password authentication disabled
- **NSG Rules**: Allow only necessary ports (22, 80)
- **Cloud-Init**: Automated, repeatable VM configuration

## Data Flow

### SSH Access
1. User connects to Public IP on port 22
2. NSG checks rule (priority 1001) - ALLOW
3. Traffic routed to NIC private IP
4. VM receives connection
5. SSH key authentication required

### HTTP Access
1. Browser connects to Public IP on port 80
2. NSG checks rule (priority 1002) - ALLOW
3. Traffic routed to NIC private IP
4. Nginx on VM serves web page
5. Response sent back through same path

### Data Persistence
1. Application writes to /mnt/data
2. Data stored on managed disk (sdc)
3. Survives VM stop/start/resize
4. Independent lifecycle from VM
5. Can be backed up separately