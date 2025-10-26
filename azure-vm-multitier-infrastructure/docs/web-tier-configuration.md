# Web Tier Configuration - Nginx Reverse Proxy

## Overview
Nginx on Web VM (10.0.1.4) configured as reverse proxy to App tier, serving static content and forwarding API requests.

## Architecture
```
Internet (Users)
    │
    ▼
Web VM: 10.0.1.4 (Nginx)
    │
    ├─→ Static Content (/var/www/html)
    │   - index.html
    │   - 404.html
    │   - 50x.html
    │
    └─→ API Proxy (/api/*)
        └─→ App VM: 10.0.2.4:8080 (Node.js)
                │
                └─→ Database VM: 10.0.3.4:5432 (PostgreSQL)
```

## Nginx Configuration

### Location
`/etc/nginx/sites-available/default`

### Key Configuration Blocks

#### Upstream Backend
```nginx
upstream api_backend {
    server 10.0.2.4:8080;
    keepalive 32;
}
```

#### API Proxy
```nginx
location /api/ {
    proxy_pass http://api_backend;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    ...
}
```

#### Static Files
```nginx
location / {
    root /var/www/html;
    try_files $uri $uri/ =404;
}
```

## Request Routing

| Request Path | Handled By | Action |
|--------------|------------|--------|
| `/` | Nginx | Serve index.html |
| `/api/tasks` | Proxy → App | Forward to 10.0.2.4:8080 |
| `/health` | Proxy → App | Forward to 10.0.2.4:8080 |
| `/static.html` | Nginx | Serve from /var/www/html |
| `/nonexistent` | Nginx | Return 404.html |

## Static Files

### HTML Files Location
`/var/www/html/`

| File | Purpose |
|------|---------|
| `index.html` | Main application page |
| `404.html` | Custom 404 error page |
| `50x.html` | Server error page |

## Logs

### Access Log
**Location:** `/var/log/nginx/api-access.log`

**View:**
```bash
sudo tail -f /var/log/nginx/api-access.log
```

**Example entry:**
192.168.1.100 - - [24/Oct/2025:12:00:00 +0RetryClaude does not have the ability to run the code it generates yet.A000] "GET /api/tasks HTTP/1.1" 200 512 "-" "curl/7.81.0"

### Error Log
**Location:** `/var/log/nginx/api-error.log`

**View:**
```bash
sudo tail -f /var/log/nginx/api-error.log
```

## Configuration Management

### Test Configuration
```bash
sudo nginx -t
```

### Reload Configuration
```bash
sudo systemctl reload nginx
```

### Restart Nginx
```bash
sudo systemctl restart nginx
```

### Check Status
```bash
sudo systemctl status nginx
```

## Proxy Settings

### Timeouts
- **Connect timeout:** 10 seconds
- **Send timeout:** 30 seconds
- **Read timeout:** 30 seconds

### Headers Forwarded
- `Host`: Original host header
- `X-Real-IP`: Client's real IP address
- `X-Forwarded-For`: Proxy chain
- `X-Forwarded-Proto`: Original protocol (http/https)

### Connection Pooling
- **Keepalive connections:** 32
- **Keepalive timeout:** 60 seconds

## Security Headers

Nginx adds these security headers to all responses:
```nginx
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
```

**Server tokens:** Hidden (Nginx version not exposed)

## Error Handling

### Upstream Errors
If app tier is down:
- **First attempt:** Try to connect
- **Retry:** Up to 2 times
- **Fallback:** Return 502 Bad Gateway
- **Error page:** Show 50x.html

### Client Errors
- **404 Not Found:** Custom 404.html page
- **400 Bad Request:** Default Nginx error

## Performance Optimization

### Buffering
```nginx
proxy_buffering on;
proxy_buffer_size 4k;
proxy_buffers 8 4k;
```

**Benefits:**
- Reduces memory usage
- Improves response time
- Handles slow clients better

### HTTP Version
```nginx
proxy_http_version 1.1;
```

**Benefits:**
- Enables keepalive connections
- Better performance with Node.js

## Monitoring

### Check Nginx Process
```bash
ps aux | grep nginx
```

### Check Listening Ports
```bash
sudo netstat -tlnp | grep nginx
# Should show: 0.0.0.0:80
```

### Test Endpoints
```bash
# Health check
curl http://localhost/health

# API endpoint
curl http://localhost/api/tasks

# Static page
curl http://localhost/
```

## Troubleshooting

### Issue: 502 Bad Gateway

**Cause:** App tier is down or unreachable

**Check:**
```bash
# Test if app VM is reachable
curl http://10.0.2.4:8080/health

# If fails, SSH to app VM and check PM2
ssh azureuser@10.0.2.4
pm2 status
pm2 logs task-api
```

**Solution:**
```bash
# Restart app on app VM
pm2 restart task-api
```

---

### Issue: 404 for API requests

**Cause:** Wrong proxy_pass configuration

**Check:**
```bash
sudo nginx -t
sudo cat /etc/nginx/sites-available/default | grep proxy_pass
```

**Solution:**
```bash
# Verify upstream is correct
# Should be: proxy_pass http://api_backend;
```

---

### Issue: Static files not loading

**Cause:** File permissions or location

**Check:**
```bash
ls -la /var/www/html/
# Files should be owned by www-data

# Check Nginx error log
sudo tail -20 /var/log/nginx/api-error.log
```

**Solution:**
```bash
sudo chown -R www-data:www-data /var/www/html/
sudo chmod 644 /var/www/html/*.html
sudo systemctl reload nginx
```

---

### Issue: Slow response times

**Check:**
```bash
# Test direct to app tier (should be fast)
curl -w "Time: %{time_total}s\n" http://10.0.2.4:8080/api/tasks

# Test through proxy (compare)
curl -w "Time: %{time_total}s\n" http://localhost/api/tasks
```

**If proxy is slow:**
- Check buffer settings
- Check keepalive settings
- Monitor app tier resources

---

## Deployment

### Automated Deployment
```bash
# From project root
./scripts/deploy-web-config.sh
```

### Manual Deployment

**Step 1: Copy configuration**
```bash
sudo cp /home/azureuser/nginx/api-proxy.conf /etc/nginx/sites-available/default
```

**Step 2: Copy HTML files**
```bash
sudo cp /home/azureuser/nginx/html/*.html /var/www/html/
sudo chown www-data:www-data /var/www/html/*.html
```

**Step 3: Test and reload**
```bash
sudo nginx -t
sudo systemctl reload nginx
```

## Testing Checklist

- [ ] Static homepage loads
- [ ] `/health` returns JSON from app tier
- [ ] `/api/tasks` returns tasks from database
- [ ] POST to `/api/tasks` creates new task
- [ ] 404 page displays for invalid URLs
- [ ] Nginx logs show requests
- [ ] No errors in error log
- [ ] Response times < 1 second

## Configuration Files

### Main Config
- `/etc/nginx/nginx.conf` (global settings)
- `/etc/nginx/sites-available/default` (site config)
- `/etc/nginx/sites-enabled/default` (symlink)

### HTML Files
- `/var/www/html/index.html`
- `/var/www/html/404.html`
- `/var/www/html/50x.html`

### Logs
- `/var/log/nginx/access.log` (general access log)
- `/var/log/nginx/error.log` (general error log)
- `/var/log/nginx/api-access.log` (API-specific access log)
- `/var/log/nginx/api-error.log` (API-specific error log)

## Backup and Restore

### Backup Configuration
```bash
# Create backup
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup-$(date +%Y%m%d)

# List backups
ls -la /etc/nginx/sites-available/*.backup*
```

### Restore Configuration
```bash
# Restore from backup
sudo cp /etc/nginx/sites-available/default.backup-YYYYMMDD /etc/nginx/sites-available/default
sudo nginx -t
sudo systemctl reload nginx
```

## Future Enhancements

- [ ] HTTPS/SSL with Let's Encrypt
- [ ] Rate limiting
- [ ] Request caching
- [ ] Load balancing (multiple app VMs)
- [ ] Web Application Firewall (WAF) rules
- [ ] Compression (gzip)
- [ ] Static asset optimization

---

**Status:** Web tier configured as reverse proxy ✅  
**Static content:** Serving successfully ✅  
**API proxy:** Forwarding to app tier ✅  
**Complete 3-tier flow:** Working end-to-end ✅