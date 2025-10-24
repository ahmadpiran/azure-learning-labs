# Database Tier - Setup Documentation

## Overview
PostgreSQL 16 database server in the Data subnet (10.0.3.0/24) - most restricted, private only.

## VM Details

**Name:** vm-db-001  
**Private IP:** 10.0.3.4 (dynamic, check with `terraform output db_vm_private_ip`)  
**Subnet:** Data (10.0.3.0/24)  
**Public IP:** None (most restricted)  
**OS:** Ubuntu 22.04 LTS  
**Size:** Standard_B1s (1 vCPU, 1 GiB RAM)  
**Data Disk:** 64GB (mounted at `/mnt/dbdata`)  

## Installed Software

- **PostgreSQL:** 16.x
- **PostgreSQL Contrib:** Additional modules
- **PostgreSQL Client:** Command-line tools

## Database Configuration

**Database Name:** taskdb  
**Database User:** taskuser  
**Database Password:** (set in terraform.tfvars - not committed)  
**Port:** 5432  
**Data Directory:** /mnt/dbdata/postgresql  

## Schema

### Tasks Table
```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Access

### SSH Access (via Bastion)
```bash
# Step 1: SSH to bastion
ssh -i ~/.ssh/azure_vm_key azureuser@<BASTION_IP>

# Step 2: From bastion, SSH to database VM
ssh azureuser@10.0.3.4
```

### Database Access (from App VM)
```bash
# From app VM:
psql -h 10.0.3.4 -U taskuser -d taskdb
# Enter password when prompted
```

### Connection String
```
postgresql://taskuser:PASSWORD@10.0.3.4:5432/taskdb
```

## Network Connectivity

### Inbound (Who can reach this VM)
| Source | Port | Allowed? | Purpose |
|--------|------|----------|---------|
| Internet | Any | ❌ No | Most restricted subnet |
| Web Subnet (10.0.1.0/24) | Any | ❌ No | No direct web→db access |
| App Subnet (10.0.2.0/24) | 5432 | ✅ Yes | Database queries |
| Bastion (10.0.10.0/24) | 22 | ✅ Yes | SSH admin access |

### Outbound (Where this VM can reach)
| Destination | Port | Allowed? | Purpose |
|-------------|------|----------|---------|
| Internet | 443 | ✅ Yes | HTTPS for updates only |
| Internet | 80 | ❌ No | HTTP blocked |
| Other Subnets | Any | ❌ No | Databases don't initiate |

**💡 Most Restricted:** Database tier has the most restrictive outbound rules.

## PostgreSQL Configuration

### Listen Address
```
listen_addresses = '*'  # Listen on all interfaces (within subnet)
```

### Authentication (pg_hba.conf)
```
host    all    all    10.0.2.0/24    md5  # App subnet only
```

**Security:** Only app subnet (10.0.2.0/24) can connect to PostgreSQL.

## Common Operations

### Check PostgreSQL Status
```bash
sudo systemctl status postgresql
```

### Restart PostgreSQL
```bash
sudo systemctl restart postgresql
```

### View PostgreSQL Logs
```bash
sudo tail -f /var/log/postgresql/postgresql-16-main.log
```

### Connect as Postgres User
```bash
sudo -u postgres psql
```

### Connect as App User
```bash
psql -h localhost -U taskuser -d taskdb
```

### Backup Database
```bash
pg_dump -h localhost -U taskuser taskdb > backup.sql
```

### Restore Database
```bash
psql -h localhost -U taskuser taskdb < backup.sql
```

## SQL Queries

### View All Tasks
```sql
SELECT * FROM tasks ORDER BY created_at DESC;
```

### Insert New Task
```sql
INSERT INTO tasks (title, description) 
VALUES ('New Task', 'Task description');
```

### Update Task
```sql
UPDATE tasks SET completed = true WHERE id = 1;
```

### Delete Task
```sql
DELETE FROM tasks WHERE id = 1;
```

### Count Tasks
```sql
SELECT COUNT(*) FROM tasks;
SELECT COUNT(*) FROM tasks WHERE completed = true;
```

## Data Disk Management

### Check Disk Usage
```bash
df -h /mnt/dbdata
```

### Check PostgreSQL Data Size
```bash
sudo du -sh /mnt/dbdata/postgresql
```

### List Databases and Sizes
```sql
SELECT pg_database.datname, 
       pg_size_pretty(pg_database_size(pg_database.datname)) AS size
FROM pg_database
ORDER BY pg_database_size(pg_database.datname) DESC;
```

## Troubleshooting

### PostgreSQL Won't Start
```bash
# Check logs
sudo tail -50 /var/log/postgresql/postgresql-16-main.log

# Check if port is in use
sudo netstat -tlnp | grep 5432

# Check data directory permissions
ls -la /mnt/dbdata/postgresql/

# Should be owned by postgres:postgres with 700 permissions
```

### Cannot Connect from App VM
```bash
# From database VM, check PostgreSQL is listening
sudo netstat -tlnp | grep 5432
# Should show: 0.0.0.0:5432

# Check pg_hba.conf
sudo cat /etc/postgresql/16/main/pg_hba.conf | grep "10.0.2"
# Should show: host all all 10.0.2.0/24 md5

# Check NSG rules
az network nsg rule show -g rg-vm-lab-dev --nsg-name nsg-data -n Allow-PostgreSQL-From-App
```

### Authentication Failed
```bash
# Reset password
sudo -u postgres psql
ALTER USER taskuser WITH PASSWORD 'NewPassword';
\q
```

### Data Disk Not Mounted
```bash
# Check if disk is attached
lsblk

# Check fstab
cat /etc/fstab | grep dbdata

# Mount manually
sudo mount /mnt/dbdata

# Check mount
df -h | grep dbdata
```

## Security Notes

- ✅ No public IP (cannot be reached from internet)
- ✅ SSH only from bastion
- ✅ PostgreSQL connections only from app subnet
- ✅ Password authentication for database
- ✅ Outbound limited to HTTPS only
- ⚠️ Database password in cloud-init (in production, use Azure Key Vault)
- ⚠️ No SSL/TLS for PostgreSQL connections yet (will add later)

## Performance Considerations

### Current Setup (B1s)
- 1 vCPU, 1 GiB RAM
- Good for: Learning, development, small apps
- Not good for: Production, high load

### Recommended for Production
- Standard_B2s or higher (2 vCPU, 4 GiB RAM)
- Premium SSD for data disk
- Read replicas for scaling
- Connection pooling (PgBouncer)


---

**Status:** Database VM deployed and operational ✅  
**PostgreSQL:** Installed and configured ✅  
**Connectivity:** App → Database tested ✅  
**Next:** Step 3 - Build and Deploy the API