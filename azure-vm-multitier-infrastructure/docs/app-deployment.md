# Application Deployment Guide

## Overview
Node.js Task Manager API deployed on App VM (10.0.2.4) in the App subnet.

## Deployment Architecture
```
Local Machine
    │
    ├─→ SCP to Bastion
    │       │
    │       └─→ SCP to App VM
    │               │
    │               └─→ npm install
    │               └─→ PM2 start
    │
    └─→ Application running on App VM:8080
```

## Deployed Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `server.js` | /home/azureuser/app/ | Main API server |
| `db.js` | /home/azureuser/app/ | Database connection |
| `package.json` | /home/azureuser/app/ | Dependencies |
| `.env` | /home/azureuser/app/ | Configuration |
| `node_modules/` | /home/azureuser/app/ | NPM packages |

## Deployment Process

### Automated Deployment
```bash
# From project root
./scripts/deploy-app.sh
```

### Manual Deployment

**Step 1: Copy files to bastion**
```bash
scp -i ~/.ssh/azure_vm_key -r app/ azureuser@<BASTION_IP>:/home/azureuser/
**Step 2: SSH to bastion**
```bash
ssh -i ~/.ssh/azure_vm_key azureuser@<BASTION_IP>
```

**Step 3: Copy from bastion to app VM**
```bash
scp -r /home/azureuser/app/ azureuser@10.0.2.4:/home/azureuser/
```

**Step 4: SSH to app VM**
```bash
ssh azureuser@10.0.2.4
```

**Step 5: Install and start**
```bash
cd /home/azureuser/app

# Install dependencies
npm install

# Create .env file
cat > .env << EOF
DB_HOST=10.0.3.4
DB_PORT=5432
DB_NAME=taskdb
DB_USER=taskuser
DB_PASSWORD=<EnterAPasswordHere>
PORT=8080
NODE_ENV=production
EOF

# Test database connection
npm test

# Start with PM2
pm2 start server.js --name task-api
pm2 save
```

---

## Application Management

### Check Status
```bash
pm2 status
pm2 info task-api
```

### View Logs
```bash
# Real-time logs
pm2 logs task-api

# Last 100 lines
pm2 logs task-api --lines 100

# Error logs only
pm2 logs task-api --err
```

### Restart Application
```bash
pm2 restart task-api
```

### Stop Application
```bash
pm2 stop task-api
```

### Delete from PM2
```bash
pm2 delete task-api
```

### Monitor Resources
```bash
pm2 monit
```

---

## Testing

### Local Testing (on App VM)
```bash
# Health check
curl http://localhost:8080/health

# Get all tasks
curl http://localhost:8080/api/tasks

# Create task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","description":"Testing"}'
```

### From Web VM
```bash
curl http://10.0.2.4:8080/health
curl http://10.0.2.4:8080/api/tasks
```

### Automated Tests
```bash
# Copy test script to app VM
scp scripts/testing/test-api.sh azureuser@10.0.2.4:~/

# Run tests
ssh azureuser@10.0.2.4 "bash ~/test-api.sh"
```

---

## Configuration

### Environment Variables (.env)
```bash
DB_HOST=10.0.3.4          # Database VM IP
DB_PORT=5432              # PostgreSQL port
DB_NAME=taskdb            # Database name
DB_USER=taskuser          # Database user
DB_PASSWORD=***           # Database password (sensitive)
PORT=8080                 # API server port
NODE_ENV=production       # Environment
```

### Update Configuration
```bash
# SSH to app VM
cd /home/azureuser/app

# Edit .env
vim .env

# Restart application
pm2 restart task-api
```

---

## Troubleshooting

### Application Won't Start

**Check PM2 logs:**
```bash
pm2 logs task-api --err
```

**Common issues:**
- Database connection failed → Check DB_HOST in .env
- Port already in use → Check `netstat -tlnp | grep 8080`
- Module not found → Run `npm install`

**Solution:**
```bash
cd /home/azureuser/app

# Reinstall dependencies
rm -rf node_modules
npm install

# Verify .env exists and is correct
cat .env

# Test database connection
npm test

# Restart
pm2 restart task-api
```

---

### Cannot Connect to Database

**Test connectivity:**
```bash
# From app VM
psql -h 10.0.3.4 -U taskuser -d taskdb

# If fails, check:
# 1. Database VM is running
# 2. PostgreSQL is running on DB VM
# 3. NSG allows app → data on port 5432
# 4. Credentials are correct in .env
```

**Check database VM:**
```bash
# SSH to database VM (via bastion)
ssh azureuser@10.0.3.4

# Check PostgreSQL status
sudo systemctl status postgresql

# Check if listening
sudo netstat -tlnp | grep 5432
# Should show: 0.0.0.0:5432

# Check pg_hba.conf
sudo cat /etc/postgresql/14/main/pg_hba.conf | grep "10.0.2"
```

---

### API Returns Errors

**500 Internal Server Error:**
- Check PM2 logs: `pm2 logs task-api`
- Usually database connection or query errors

**404 Not Found:**
- Check endpoint URL
- Verify routes in server.js

**400 Bad Request:**
- Check request body format
- Verify Content-Type header: `application/json`

---

### High CPU/Memory Usage

**Check resources:**
```bash
pm2 monit

# Or
htop
```

**Restart if needed:**
```bash
pm2 restart task-api
```

---

## Updates and Redeployment

### Update Application Code

**Option 1: Full redeployment**
```bash
# From local machine
./scripts/deploy-app.sh
```

**Option 2: Manual update**
```bash
# Edit files locally
# Then copy and restart:
scp -i ~/.ssh/azure_vm_key app/server.js azureuser@<BASTION_IP>:/home/azureuser/app/
ssh azureuser@<BASTION_IP> "scp app/server.js azureuser@10.0.2.4:/home/azureuser/app/"
ssh -J azureuser@<BASTION_IP> azureuser@10.0.2.4 "cd app && pm2 restart task-api"
```

---

## Performance Optimization

### Current Setup (B1s VM)
- 1 vCPU, 1 GiB RAM
- Good for: ~100 concurrent users
- Bottleneck: Database queries

### Improvements for Production
1. **VM Scaling**: Use Standard_B2s or higher
2. **Connection Pooling**: Already implemented in db.js
3. **Caching**: Add Redis for frequently accessed data
4. **Load Balancing**: Multiple app VMs behind load balancer
5. **Monitoring**: Add application performance monitoring (APM)

---

## Security Considerations

### Current Security
- ✅ No public IP (app VM is private)
- ✅ Parameterized SQL queries (no injection)
- ✅ Input validation on endpoints
- ✅ Environment variables for secrets
- ✅ CORS enabled

### Future Improvements (Phase 4)
- [ ] JWT authentication
- [ ] Rate limiting
- [ ] HTTPS/TLS
- [ ] API keys
- [ ] Request logging
- [ ] Secrets in Azure Key Vault

---

## Backup and Recovery

### Backup Application
```bash
# From app VM
cd /home/azureuser
tar -czf app-backup-$(date +%Y%m%d).tar.gz app/

# Download to local machine
scp -i ~/.ssh/azure_vm_key \
  -J azureuser@<BASTION_IP> \
  azureuser@10.0.2.4:/home/azureuser/app-backup-*.tar.gz \
  ./backups/
```

### Restore from Backup
```bash
# Upload backup
scp -i ~/.ssh/azure_vm_key backup.tar.gz azureuser@<BASTION_IP>:~/
ssh azureuser@<BASTION_IP> "scp backup.tar.gz azureuser@10.0.2.4:~/"

# SSH to app VM and restore
ssh -J azureuser@<BASTION_IP> azureuser@10.0.2.4
cd /home/azureuser
tar -xzf backup.tar.gz
cd app
npm install
pm2 restart task-api
```

---

## Monitoring and Logging

### View Real-time Logs
```bash
pm2 logs task-api -f
```

### Application Logs Location
```bash
# PM2 logs
~/.pm2/logs/task-api-out.log     # stdout
~/.pm2/logs/task-api-error.log   # stderr
```

### Log Rotation
PM2 handles log rotation automatically, but you can configure:
```bash
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

---

## API Endpoints Reference

### Base URL (from app VM)
```
http://localhost:8080
```

### Base URL (from web VM)
```
http://10.0.2.4:8080
```

### Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /health | Health check |
| GET | / | API info |
| GET | /api/tasks | List all tasks |
| GET | /api/tasks/:id | Get single task |
| POST | /api/tasks | Create task |
| PUT | /api/tasks/:id | Update task |
| DELETE | /api/tasks/:id | Delete task |

Full API documentation: See `app/README.md`

---

**Status:** Application deployed and operational ✅  
**API:** Running on App VM port 8080 ✅  
**Database:** Connected and functional ✅  
**Next:** Configure web tier reverse proxy (Step 4)