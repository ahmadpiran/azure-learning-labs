#!/bin/bash

# Deploy Nginx configuration and static files to Web VM
# Usage: ./scripts/deploy-web-config.sh

set -e

echo "=========================================="
echo "  Web Tier Configuration Deployment"
echo "=========================================="
echo ""

# Configuration
BASTION_IP=$(cd terraform && terraform output -raw bastion_public_ip)
WEB_VM_IP=$(cd terraform && terraform output -raw vm_private_ip)

echo "Configuration:"
echo "  Bastion IP: $BASTION_IP"
echo "  Web VM IP: $WEB_VM_IP"
echo ""

# Step 1: Copy files to bastion
echo "Step 1: Copying files to bastion..."
scp -i ~/.ssh/azure_vm_key -r scripts/nginx/ azureuser@$BASTION_IP:/home/azureuser/
echo "✓ Files copied to bastion"
echo ""

# Step 2: Deploy to web VM
echo "Step 2: Deploying to web VM..."
ssh -i ~/.ssh/azure_vm_key azureuser@$BASTION_IP << EOF
  # Copy files from bastion to web VM
  scp -r /home/azureuser/nginx/ azureuser@$WEB_VM_IP:/home/azureuser/
  
  # SSH to web VM and configure
  ssh azureuser@$WEB_VM_IP << 'INNER_EOF'
    # Backup existing config
    sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
    
    # Copy new Nginx configuration
    sudo cp /home/azureuser/nginx/api-proxy.conf /etc/nginx/sites-available/default
    
    # Copy HTML files
    sudo cp /home/azureuser/nginx/html/index.html /var/www/html/
    sudo cp /home/azureuser/nginx/html/404.html /var/www/html/
    sudo cp /home/azureuser/nginx/html/50x.html /var/www/html/
    
    # Set permissions
    sudo chown -R www-data:www-data /var/www/html/
    sudo chmod 644 /var/www/html/*.html
    
    # Test Nginx configuration
    echo "Testing Nginx configuration..."
    sudo nginx -t
    
    # Reload Nginx
    echo "Reloading Nginx..."
    sudo systemctl reload nginx
    
    echo "✓ Web configuration deployed!"
INNER_EOF
EOF

echo ""
echo "=========================================="
echo "  Deployment Complete!"
echo "=========================================="
echo ""
echo "Test the application:"
echo "  curl http://$(cd terraform && terraform output -raw public_ip_address)/"
echo "  curl http://$(cd terraform && terraform output -raw public_ip_address)/api/tasks"
echo ""
echo "Or open in browser:"
echo "  http://$(cd terraform && terraform output -raw public_ip_address)/"
echo ""