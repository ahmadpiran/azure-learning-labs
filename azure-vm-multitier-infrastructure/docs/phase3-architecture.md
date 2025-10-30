# Phase 3 - Complete 3-Tier Architecture

## Overview
Production-ready 3-tier web application architecture deployed on Azure with complete network segmentation, security controls, and end-to-end functionality.

## Architecture Diagram
```
                                 INTERNET
                                     │
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    │   HTTP/HTTPS   │   SSH          │
                    │   (80, 443)    │   (22)         │
                    │                │                │
                    ▼                ▼                │
        ╔═══════════════════╗   ╔═══════════════════╗│
        ║   WEB TIER        ║   ║   MANAGEMENT      ║│
        ║   10.0.1.0/24     ║   ║   10.0.10.0/24    ║│
        ║                   ║   ║                   ║│
        ║  vm-lab-001       ║   ║  vm-bastion-001   ║│
        ║  - Nginx          ║   ║  - SSH Gateway    ║│
        ║  - Reverse Proxy  ║   ║  - Jump Host      ║│
        ║  - Static Files   ║   ║                   ║│
        ║                   ║   ║  Can access:      ║│
        ║  Public IP: Yes   ║   ║  - All VMs (SSH)  ║│
        ╚═════════┬═════════╝   ╚═══════════┬═══════╝│
                  │                         │         │
                  │ Proxy /api/*            │         │
                  │ to 10.0.2.4:8080       │         │
                  │                         │         │
                  ▼                         ▼         │
        ╔═══════════════════╗         ╔═══════════════╗
        ║   APP TIER        ║         ║               ║
        ║   10.0.2.0/24     ║◄────────║  SSH Access   ║
        ║                   ║         ║               ║
        ║  vm-app-001       ║         ╚═══════════════╝
        ║  - Node.js 18     ║                │
        ║  - Express API    ║                │
        ║  - REST Endpoints ║                │
        ║  - PM2 Manager    ║                │
        ║                   ║                │
        ║  Public IP: No    ║                │
        ╚═════════┬═════════╝                │
                  │                          │
                  │ PostgreSQL               │
                  │ 10.0.3.4:5432           │
                  │                          │
                  ▼                          ▼
        ╔═══════════════════╗         ╔═════════════╗
        ║   DATA TIER       ║         ║             ║
        ║   10.0.3.0/24     ║◄────────║ SSH Access  ║
        ║                   ║         ║             ║
        ║  vm-db-001        ║         ╚═════════════╝
        ║  - PostgreSQL 14  ║
        ║  - taskdb         ║
        ║  - Data Disk 64GB ║
        ║                   ║
        ║  Public IP: No    ║
        ╚═══════════════════╝
```

## Virtual Machines

| VM | Subnet | Private IP | Public IP | Purpose | Software |
|----|--------|------------|-----------|---------|----------|
| vm-lab-001 | Web (10.0.1.0/24) | 10.0.1.4 | Yes | Web server, reverse proxy | Nginx |
| vm-app-001 | App (10.0.2.0/24) | 10.0.2.4 | No | API server | Node.js 18, PM2 |
| vm-db-001 | Data (10.0.3.0/24) | 10.0.3.4 | No | Database | PostgreSQL 14 |
| vm-bastion-001 | Mgmt (10.0.10.0/24) | 10.0.10.4 | Yes | SSH gateway | Ubuntu 22.04 |

## Network Security Groups

### NSG Rules Summary

| Source | Destination | Port | Protocol | Action | NSG |
|--------|-------------|------|----------|--------|-----|
| Internet | Web | 80, 443 | TCP | Allow | nsg-web |
| Internet | Web | 22 | TCP | Deny | nsg-web |
| Mgmt Subnet | Web | 22 | TCP | Allow | nsg-web |
| Web Subnet | App | 8080 | TCP | Allow | nsg-app |
| Internet | App | Any | Any | Deny | nsg-app |
| Mgmt Subnet | App | 22 | TCP | Allow | nsg-app |
| App Subnet | Data | 5432 | TCP | Allow | nsg-data |
| Internet | Data | Any | Any | Deny | nsg-data |
| Mgmt Subnet | Data | 22 | TCP | Allow | nsg-data |
| Your IP | Bastion | 22 | TCP | Allow | nsg-mgmt |
| Internet | Bastion | 22 | TCP | Deny | nsg-mgmt |
| Bastion | All Subnets | 22 | TCP | Allow | All NSGs |

## Request Flow Examples

### Example 1: User Views Homepage
```
1. User Browser
   └─→ HTTP GET http://[PUBLIC_IP]/
       
2. Web VM (Nginx)
   ├─→ Receives request on port 80
   ├─→ Matches location / (static content)
   ├─→ Serves /var/www/html/index.html
   └─→ Returns HTML

3. User Browser
   └─→ Displays page
```

### Example 2: User Fetches Tasks (AJAX)
```
1. User Browser (JavaScript)
   └─→ HTTP GET http://[PUBLIC_IP]/api/tasks
       
2. Web VM (Nginx)
   ├─→ Receives request on port 80
   ├─→ Matches location /api/
   ├─→ Proxies to http://10.0.2.4:8080/api/tasks
   └─→ Forwards request

3. App VM (Node.js)
   ├─→ Receives proxied request
   ├─→ Parses route: GET /api/tasks
   ├─→ Executes: SELECT * FROM tasks ORDER BY created_at DESC
   └─→ Sends query to 10.0.3.4:5432

4. Database VM (PostgreSQL)
   ├─→ Receives SQL query
   ├─→ Executes SELECT on tasks table
   ├─→ Returns rows
   └─→ Sends data back

5. App VM (Node.js)
   ├─→ Receives database results
   ├─→ Formats as JSON: {success:true, data:[...]}
   └─→ Returns JSON response

6. Web VM (Nginx)
   ├─→ Receives response from app VM
   ├─→ Adds security headers
   └─→ Forwards to client

7. User Browser (JavaScript)
   ├─→ Receives JSON
   ├─→ Parses data
   └─→ Updates DOM with tasks
```

### Example 3: User Creates New Task
```
1. User Browser (JavaScript)
   └─→ HTTP POST http://[PUBLIC_IP]/api/tasks
       Headers: Content-Type: application/json
       Body: {"title":"New Task","description":"Test"}
       
2. Web VM (Nginx)
   ├─→ Receives POST request
   ├─→ Proxies to App VM
   └─→ Forwards body

3. App VM (Node.js)
   ├─→ Receives POST /api/tasks
   ├─→ Validates: title present ✓
   ├─→ Executes: INSERT INTO tasks (title, description) VALUES ($1, $2)
   └─→ Sends INSERT to database

4. Database VM (PostgreSQL)
   ├─→ Receives INSERT query
   ├─→ Validates and inserts row
   ├─→ Returns new row with ID
   └─→ Sends response

5. App VM (Node.js)
   ├─→ Receives new task data
   ├─→ Formats as JSON with HTTP 201
   └─→ Returns: {success:true, data:{id:X, title:...}}

6. Web VM (Nginx)
   └─→ Forwards response

7. User Browser
   └─→ Receives new task, updates UI
```

### Example 4: Admin SSH Access
```
1. Admin Workstation
   └─→ SSH to bastion: ssh -i key azureuser@[BASTION_PUBLIC_IP]

2. Bastion VM
   ├─→ NSG allows (Your IP → Bastion:22)
   ├─→ SSH authentication with key
   └─→ Login successful

3. From Bastion
   └─→ SSH to web VM: ssh azureuser@10.0.1.4
       └─→ NSG allows (Mgmt Subnet → Web:22)
       
   └─→ SSH to app VM: ssh azureuser@10.0.2.4
       └─→ NSG allows (Mgmt Subnet → App:22)
       
   └─→ SSH to db VM: ssh azureuser@10.0.3.4
       └─→ NSG allows (Mgmt Subnet → Data:22)
```

## Technology Stack

### Web Tier
- **OS:** Ubuntu 24.04 LTS
- **Web Server:** Nginx 1.18+
- **Configuration:** Reverse proxy with upstream pooling
- **Static Content:** HTML5, CSS3, JavaScript (Vanilla)

### Application Tier
- **OS:** Ubuntu 24.04 LTS
- **Runtime:** Node.js 18 LTS
- **Framework:** Express.js 4.18
- **Database Client:** node-postgres (pg) 8.11
- **Process Manager:** PM2
- **Dependencies:** cors, dotenv

### Data Tier
- **OS:** Ubuntu 24.04 LTS
- **Database:** PostgreSQL 16
- **Storage:** 64GB managed disk (ext4)
- **Schema:** Single database (taskdb), single table (tasks)

### Management Tier
- **OS:** Ubuntu 24.04 LTS
- **Purpose:** SSH gateway, jump host
- **Tools:** Standard SSH, tmux, htop

## Database Schema
```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | / | Homepage | None |
| GET | /health | Health check | None |
| GET | /api/tasks | List all tasks | None |
| GET | /api/tasks/:id | Get single task | None |
| POST | /api/tasks | Create new task | None |
| PUT | /api/tasks/:id | Update task | None |
| DELETE | /api/tasks/:id | Delete task | None |

## Security Model

### Network Security
- **Segmentation:** 4 isolated subnets
- **Firewalls:** NSGs on each subnet
- **Default Policy:** Deny all, explicit allow
- **Public Access:** Only web tier and bastion

### Application Security
- **SQL Injection:** Parameterized queries (✓)
- **XSS Protection:** Input validation, output escaping (✓)
- **CORS:** Configured and enabled (✓)
- **Authentication:** None (Phase 4)
- **Rate Limiting:** None (Phase 4)
- **HTTPS:** None yet (Phase 4)

### Data Security
- **Database Access:** App tier only
- **Credentials:** Environment variables
- **Backups:** Manual (Phase 4: automated)
- **Encryption at Rest:** Azure default
- **Encryption in Transit:** None yet (Phase 4: TLS)

## Performance Characteristics

### Response Times (Average)
- **Static Homepage:** <100ms
- **API GET requests:** <200ms
- **API POST requests:** <300ms
- **Database queries:** <50ms

### Capacity (Current Hardware)
- **Concurrent Users:** ~50-100
- **Requests/Second:** ~20-30
- **Database Connections:** Pool of 20

### Bottlenecks
1. **VM Size:** B1s (1 vCPU) - CPU bound
2. **Database Disk:** Standard HDD - I/O bound
3. **Single Instance:** No redundancy