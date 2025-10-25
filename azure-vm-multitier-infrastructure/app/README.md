# Task Manager API

REST API for managing tasks, built with Node.js, Express, and PostgreSQL.

## Architecture

This API is the middle tier (application layer) in a 3-tier architecture:
- **Web Tier** (10.0.1.0/24): Nginx reverse proxy
- **App Tier** (10.0.2.0/24): This Node.js API ⬅️ YOU ARE HERE
- **Data Tier** (10.0.3.0/24): PostgreSQL database

## API Endpoints

### Health Check
```
GET /health
```
Returns server status and version.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-10-24T12:00:00.000Z",
  "service": "task-manager-api",
  "version": "1.0.0"
}
```

---

### List All Tasks
```
GET /api/tasks
```

**Response:**
```json
{
  "success": true,
  "count": 3,
  "data": [
    {
      "id": 1,
      "title": "Setup Database",
      "description": "Install and configure PostgreSQL",
      "completed": true,
      "created_at": "2025-10-24T12:00:00.000Z"
    }
  ]
}
```

---

### Get Single Task
```
GET /api/tasks/:id
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Setup Database",
    "description": "Install and configure PostgreSQL",
    "completed": true,
    "created_at": "2025-10-24T12:00:00.000Z"
  }
}
```

**Error (404):**
```json
{
  "success": false,
  "error": "Task not found"
}
```

---

### Create New Task
```
POST /api/tasks
Content-Type: application/json

{
  "title": "New Task",
  "description": "Task description",
  "completed": false
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": 4,
    "title": "New Task",
    "description": "Task description",
    "completed": false,
    "created_at": "2025-10-24T12:00:00.000Z"
  }
}
```

**Validation Error (400):**
```json
{
  "success": false,
  "error": "Title is required"
}
```

---

### Update Task
```
PUT /api/tasks/:id
Content-Type: application/json

{
  "title": "Updated Title",
  "completed": true
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Updated Title",
    "description": "Install and configure PostgreSQL",
    "completed": true,
    "created_at": "2025-10-24T12:00:00.000Z"
  }
}
```

---

### Delete Task
```
DELETE /api/tasks/:id
```

**Response:**
```json
{
  "success": true,
  "message": "Task deleted successfully",
  "data": {
    "id": 1,
    "title": "Setup Database",
    ...
  }
}
```

---

## Installation

### Prerequisites
- Node.js 18+
- PostgreSQL database accessible at 10.0.3.4
- Database credentials

### Setup

1. **Install dependencies:**
```bash
npm install
```

2. **Create environment file:**
```bash
cp .env.example .env
# Edit .env with your database credentials
```

3. **Test database connection:**
```bash
npm test
```

4. **Start server:**
```bash
npm start
```

Server will run on port 8080.

---

## Testing

### Using curl

**Get all tasks:**
```bash
curl http://localhost:8080/api/tasks
```

**Create task:**
```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task","description":"Testing API"}'
```

**Update task:**
```bash
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'
```

**Delete task:**
```bash
curl -X DELETE http://localhost:8080/api/tasks/1
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | 8080 | API server port |
| `DB_HOST` | 10.0.3.4 | Database server IP |
| `DB_PORT` | 5432 | PostgreSQL port |
| `DB_NAME` | taskdb | Database name |
| `DB_USER` | taskuser | Database user |
| `DB_PASSWORD` | - | Database password |
| `NODE_ENV` | production | Environment (production/development) |

---

## Project Structure
```
app/
├── server.js          # Main API server
├── db.js              # Database connection module
├── package.json       # Dependencies
├── .env.example       # Environment template
├── .env               # Environment variables (not committed)
├── test-connection.js # Database connection test
└── README.md          # This file
```

---

## Security Notes

- ✅ Input validation on all endpoints
- ✅ SQL injection prevention (parameterized queries)
- ✅ Error messages don't expose sensitive info
- ✅ Database credentials in environment variables
- ⚠️ No authentication/authorization yet
- ⚠️ No rate limiting yet
- ⚠️ No HTTPS yet (handled by web tier)

---

## Error Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (validation error) |
| 404 | Not Found |
| 500 | Internal Server Error |

---

## Monitoring

View logs in real-time:
```bash
pm2 logs task-api
```

Check server status:
```bash
pm2 status
```

---

## Deployment

Deployed on: App VM (10.0.2.4)  
Managed by: PM2 process manager  
Auto-start: Yes (PM2 configured)  

---

**Version:** 1.0.0  
**Last Updated:** 10-25-2025