#!/bin/bash

# Create .env file with your credentials
cat > /opt/deployments/production-app/.env <<'ENV_FILE'
NODE_ENV=production
PORT=3000

# Get from https://console.anthropic.com
CLAUDE_API_KEY=sk-ant-your-key-here

# Get from https://developer.squareup.com/apps
SQUARE_ACCESS_TOKEN=your-square-access-token-here
SQUARE_LOCATION_ID=your-square-location-id-here

DATABASE_URL=postgresql://postgres:password@localhost:5432/production
REDIS_URL=redis://localhost:6379
DOMAIN=localhost
ENV_FILE

echo "✅ Environment file created at /opt/deployments/production-app/.env"
echo "⚠️  Edit this file with your actual API keys:"
echo "   sudo nano /opt/deployments/production-app/.env"
