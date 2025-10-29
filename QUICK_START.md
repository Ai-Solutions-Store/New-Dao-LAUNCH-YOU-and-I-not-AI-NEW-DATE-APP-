# 24/7 Production Deployment with Square Payments

## Quick Start (3 Steps)

### 1. Set API Keys
```bash
export CLAUDE_API_KEY="sk-ant-your-key-here"
export SQUARE_ACCESS_TOKEN="your-square-token"
export SQUARE_LOCATION_ID="your-location-id"
```

### 2. Run Deployment
```bash
sudo bash start_deployment.sh
```

### 3. Verify Running
```bash
sudo pm2 status
curl http://localhost:3000/health
```

## Get API Keys

- **Claude API**: https://console.anthropic.com
- **Square API**: https://developer.squareup.com/apps

## Features

✅ Auto-restart on crash (unlimited retries)
✅ Auto-start on server reboot
✅ Square payment processing
✅ Claude AI integration
✅ PostgreSQL + Redis
✅ Nginx reverse proxy
✅ PM2 cluster mode

## Square Payment Endpoint

```bash
curl -X POST http://localhost:3000/api/payment \
  -H "Content-Type: application/json" \
  -d '{
    "sourceId": "cnon:card-nonce-ok",
    "amount": 1000,
    "currency": "USD"
  }'
```

## Management Commands

```bash
# Status
sudo pm2 status

# Logs
sudo pm2 logs

# Restart
sudo pm2 restart production-app

# Stop
sudo pm2 stop production-app

# Monitor
sudo pm2 monit
```

## Auto-Restart Features

- Restarts on crash (unlimited)
- Restarts on memory > 500MB
- Restarts on server reboot
- Exponential backoff on rapid failures
- Systemd integration for reliability

## Files

- App: `/opt/deployments/production-app`
- Logs: `/opt/logs/`
- Config: `/opt/deployments/production-app/.env`
- Scripts: `/opt/scripts/`
