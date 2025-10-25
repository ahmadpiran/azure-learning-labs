#!/bin/bash

# Deploy Task manager API to App VM
# Usage: ./scripts/deploy-app.sh

set -e

echo "=========================================="
echo "  Task Manager API Deployment"
echo "=========================================="
echo ""

# Configuration
BASTION_IP=$(cd ../terraform && terraform output -raw bastion_public_ip)
APP_VM_IP=$(cd ../terraform && terraform output -raw app_vm_private_ip)
DB_VM_IP=$(cd ../terraform && terraform output -raw db_vm_private_ip)
DB_PASSWORD=$(cd ../terraform && terraform output -raw db_connection_string | grep -oP '://.*:(\K[^@]+)')

echo "Configuration:"
echo "  Bastion IP: $BASTION_IP"
echo "  App VM IP: $APP_VM_IP"
echo "  DB VM IP: $DB_VM_IP"
echo ""

# Step 1: Copy application files to bastion
echo "Step 1: Copying application files to bastion..."
scp -i ~/.ssh/azure_vm_key -r app/ azureuser@$BASTION_IP:/home/azureuser/
echo "✓ Files copied to bastion"
echo ""

# Step 2: Copy from bastion to app VM
echo "Step 2: Deploying to app VM..."
scp -i ~/.ssh/azure_vm_key azureuser@$BASTION_IP << EOF
  # Copy files from bastion to app VM
  scp -r /home/azureuser/app/ azureuser@$APP_VM_IP:/home/azureuser/

  # SSH to app VM and setup
  ssh azureuser@$APP_VM_IP << 'INNER_EOF'
    cd /home/azureuser/app

    # Install dependencies
    echo "Installing npm dependencies..."
    npm install

    # Create .env file
    echo "Creating environment configurations..."
    cat > .env << ENV_EOF
        DB_HOST=$DB_VM_IP
        DB_PORT=5432
        DB_NAME=taskdb
        DB_USER=taskuser
        DB_PASSWORD=$DB_PASSWORD
        PORT=8080
        NODE_ENV=production
    ENV_EOF

    # Test database connection
    echo "Testing database connection..."
    npm test

    # Stop existing PM2 process if running
    pm2 delete task-api || true

    # Start with PM2
    echo "Starting API Server with PM2..."
    pm2 start server.js --name task-api
    pm2 save

    echo "✓ Application deployed and running!"
  INNER_EOF
EOF

echo ""
echo "=========================================="
echo "  Deployment Complete!"
echo "=========================================="
echo ""
echo "Test the API:"
echo "  ssh -i ~/.ssh/azure_vm_key azureuser@$BASTION_IP"
echo "  ssh azureuser@$APP_VM_IP"
echo "  curl http://localhost:8080/health"
echo "  curl http://localhost:8080/api/tasks"
echo ""