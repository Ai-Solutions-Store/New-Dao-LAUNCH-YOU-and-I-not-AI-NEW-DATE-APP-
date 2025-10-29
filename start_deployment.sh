#!/bin/bash
set -e

# Set your API keys here
export CLAUDE_API_KEY="${CLAUDE_API_KEY:-}"
export SQUARE_ACCESS_TOKEN="${SQUARE_ACCESS_TOKEN:-}"
export SQUARE_LOCATION_ID="${SQUARE_LOCATION_ID:-}"
export DEPLOY_DOMAIN="${DEPLOY_DOMAIN:-localhost}"
export DEPLOY_PORT="${DEPLOY_PORT:-3000}"

# Run deployment
sudo bash ubuntu_haiku_deploy_complete.sh

# Start the application
cd /opt/deployments/production-app
sudo pm2 start ecosystem.config.js
sudo pm2 save --force
sudo pm2 startup systemd -u root --hp /root

# Enable all services
sudo systemctl enable production-app.service
sudo systemctl enable pm2-root.service
sudo systemctl start production-app.service

echo "✅ Deployment complete and running 24/7"
echo "📊 Check status: sudo pm2 status"
echo "📝 View logs: sudo pm2 logs"
