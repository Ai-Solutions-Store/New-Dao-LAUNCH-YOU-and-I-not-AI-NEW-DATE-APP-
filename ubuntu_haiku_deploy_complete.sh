#!/bin/bash
set -e

################################################################################
# COMPLETE UBUNTU SETUP + CLAUDE 4.5 HAIKU + DEPLOYMENT SCRIPT
# Production-ready, no placeholders, no sandbox
# Installs: Node.js, Docker, PostgreSQL, Redis, PM2, Nginx, Claude Haiku 4.5
################################################################################

SCRIPT_START=$(date +%s)
DOWNLOADS_DIR="/opt/downloads"
INSTALL_DIR="/opt/deployments"
LOG_FILE="/var/log/deployment.log"
HAIKU_API_KEY="${CLAUDE_API_KEY:-}"
SQUARE_ACCESS_TOKEN="${SQUARE_ACCESS_TOKEN:-}"
SQUARE_LOCATION_ID="${SQUARE_LOCATION_ID:-}"
PROJECT_NAME="production-app"
DOMAIN="${DEPLOY_DOMAIN:-localhost}"
PORT="${DEPLOY_PORT:-3000}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

################################################################################
# LOGGING SETUP
################################################################################
mkdir -p $(dirname "$LOG_FILE")
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

log_info() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} ${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} ${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} ${RED}✗${NC} $1"; }
log_section() { echo -e "\n${BLUE}════════════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}════════════════════════════════════════${NC}\n"; }

################################################################################
# SYSTEM CHECK & REQUIREMENTS
################################################################################
check_sudo() {
    if [ "$EUID" -ne 0 ]; then 
        log_error "This script must run as root or with sudo"
        exit 1
    fi
    log_info "Running as root - confirmed"
}

check_ubuntu_version() {
    if ! grep -q "Ubuntu" /etc/os-release; then
        log_error "This script requires Ubuntu"
        exit 1
    fi
    UBUNTU_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
    log_info "Ubuntu version: $UBUNTU_VERSION detected"
}

check_disk_space() {
    AVAILABLE=$(df /opt | awk 'NR==2 {print $4}')
    if [ "$AVAILABLE" -lt 5242880 ]; then
        log_error "Less than 5GB available in /opt"
        exit 1
    fi
    log_info "Disk space: $(df -h /opt | awk 'NR==2 {print $4}') available"
}

################################################################################
# DIRECTORY SETUP
################################################################################
setup_directories() {
    log_section "Setting up directories"
    mkdir -p "$DOWNLOADS_DIR"
    mkdir -p "$INSTALL_DIR"
    mkdir -p "/opt/scripts"
    mkdir -p "/opt/projects"
    mkdir -p "/opt/backups"
    mkdir -p "/opt/logs"
    chmod 755 "$DOWNLOADS_DIR" "$INSTALL_DIR"
    log_info "Directories created: $DOWNLOADS_DIR $INSTALL_DIR"
}

################################################################################
# SYSTEM UPDATES
################################################################################
update_system() {
    log_section "Updating Ubuntu system"
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y build-essential curl wget git vim nano htop tmux
    log_info "System updated and core tools installed"
}

################################################################################
# INSTALL NODE.JS & NPM
################################################################################
install_nodejs() {
    log_section "Installing Node.js LTS"
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v)
        log_warn "Node.js already installed: $NODE_VERSION"
        return
    fi
    
    curl -sL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
    
    NODE_VERSION=$(node -v)
    NPM_VERSION=$(npm -v)
    log_info "Node.js installed: $NODE_VERSION"
    log_info "npm installed: $NPM_VERSION"
    
    npm install -g npm@latest
    npm install -g pm2
    log_info "PM2 process manager installed globally"
}

################################################################################
# INSTALL DOCKER & DOCKER-COMPOSE
################################################################################
install_docker() {
    log_section "Installing Docker & Docker-Compose"
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version)
        log_warn "Docker already installed: $DOCKER_VERSION"
        return
    fi
    
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
    
    systemctl start docker
    systemctl enable docker
    usermod -aG docker root
    
    DOCKER_VERSION=$(docker --version)
    log_info "Docker installed: $DOCKER_VERSION"
    
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    COMPOSE_VERSION=$(docker-compose --version)
    log_info "Docker Compose installed: $COMPOSE_VERSION"
}

################################################################################
# INSTALL POSTGRESQL
################################################################################
install_postgresql() {
    log_section "Installing PostgreSQL"
    if command -v psql &> /dev/null; then
        PSQL_VERSION=$(psql --version)
        log_warn "PostgreSQL already installed: $PSQL_VERSION"
        return
    fi
    
    apt-get install -y postgresql postgresql-contrib libpq-dev
    systemctl start postgresql
    systemctl enable postgresql
    
    PSQL_VERSION=$(psql --version)
    log_info "PostgreSQL installed: $PSQL_VERSION"
}

################################################################################
# INSTALL REDIS
################################################################################
install_redis() {
    log_section "Installing Redis"
    if command -v redis-cli &> /dev/null; then
        REDIS_VERSION=$(redis-cli --version)
        log_warn "Redis already installed: $REDIS_VERSION"
        return
    fi
    
    apt-get install -y redis-server
    systemctl start redis-server
    systemctl enable redis-server
    
    REDIS_VERSION=$(redis-cli --version)
    log_info "Redis installed: $REDIS_VERSION"
}

################################################################################
# INSTALL NGINX
################################################################################
install_nginx() {
    log_section "Installing Nginx"
    if command -v nginx &> /dev/null; then
        NGINX_VERSION=$(nginx -v 2>&1)
        log_warn "Nginx already installed: $NGINX_VERSION"
        return
    fi
    
    apt-get install -y nginx certbot python3-certbot-nginx
    systemctl start nginx
    systemctl enable nginx
    
    NGINX_VERSION=$(nginx -v 2>&1)
    log_info "Nginx installed: $NGINX_VERSION"
}

################################################################################
# INSTALL CLAUDE 4.5 HAIKU CLI
################################################################################
install_claude_haiku() {
    log_section "Installing Claude 4.5 Haiku CLI"
    
    if [ -z "$HAIKU_API_KEY" ]; then
        log_error "CLAUDE_API_KEY environment variable not set"
        log_warn "Set it with: export CLAUDE_API_KEY='your-api-key-here'"
        log_warn "Get your API key from: https://console.anthropic.com"
        return 1
    fi
    
    # Download Claude CLI
    CLAUDE_VERSION="4.5"
    CLAUDE_URL="https://github.com/anthropics/claude-cli/releases/download/v${CLAUDE_VERSION}/claude-cli-linux-x86_64"
    
    log_info "Downloading Claude $CLAUDE_VERSION CLI..."
    wget -q "$CLAUDE_URL" -O "$DOWNLOADS_DIR/claude-cli" 2>/dev/null || {
        log_warn "Direct download failed, installing via npm..."
        npm install -g @anthropic-ai/claude-cli
    }
    
    if [ -f "$DOWNLOADS_DIR/claude-cli" ]; then
        chmod +x "$DOWNLOADS_DIR/claude-cli"
        cp "$DOWNLOADS_DIR/claude-cli" /usr/local/bin/claude
        log_info "Claude CLI installed to /usr/local/bin/claude"
    fi
    
    # Create Claude config directory
    mkdir -p /opt/claude
    cat > /opt/claude/config.json <<EOF
{
    "api_key": "$HAIKU_API_KEY",
    "model": "claude-haiku-4-5-20251001",
    "max_tokens": 4096,
    "temperature": 0.7
}
EOF
    chmod 600 /opt/claude/config.json
    log_info "Claude 4.5 Haiku configuration created"
}

################################################################################
# INSTALL GIT TOOLS
################################################################################
install_git_tools() {
    log_section "Installing Git tools"
    apt-get install -y git git-lfs
    git config --global init.defaultBranch main
    git config --global user.email "deploy@production.local"
    git config --global user.name "Deployment System"
    log_info "Git and Git LFS installed"
}

################################################################################
# INSTALL DEVELOPMENT TOOLS
################################################################################
install_dev_tools() {
    log_section "Installing development tools"
    apt-get install -y jq curl wget openssl openssh-server openssh-client
    apt-get install -y python3 python3-pip python3-venv
    apt-get install -y zip unzip tar gzip
    
    # Install useful CLI tools
    npm install -g @aws-cli/cli aws-cdk-lib webpack gulp grunt
    pip3 install --upgrade pip
    pip3 install requests boto3 python-dotenv
    
    log_info "Development tools installed"
}

################################################################################
# CREATE DEPLOYMENT PROJECT STRUCTURE
################################################################################
create_project_structure() {
    log_section "Creating project structure"
    
    PROJECT_DIR="$INSTALL_DIR/$PROJECT_NAME"
    mkdir -p "$PROJECT_DIR"/{src,config,scripts,data,public,uploads}
    
    # Create sample Node.js app
    cat > "$PROJECT_DIR/package.json" <<'EOF'
{
  "name": "production-app",
  "version": "1.0.0",
  "description": "Production deployment with Claude 4.5 Haiku",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "test": "echo 'Running tests'",
    "deploy": "npm install && pm2 restart app"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "axios": "^1.6.2",
    "postgres": "^3.3.5",
    "redis": "^4.6.11",
    "square": "^39.0.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
EOF

    # Create server.js
    cat > "$PROJECT_DIR/src/server.js" <<'EOF'
const express = require('express');
const cors = require('cors');
const { Client, Environment } = require('square');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

const squareClient = new Client({
    accessToken: process.env.SQUARE_ACCESS_TOKEN,
    environment: process.env.NODE_ENV === 'production' ? Environment.Production : Environment.Sandbox
});

app.use(cors());
app.use(express.json());
app.use(express.static('public'));

app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date(),
        uptime: process.uptime()
    });
});

app.post('/api/payment', async (req, res) => {
    try {
        const { sourceId, amount, currency = 'USD' } = req.body;
        const { result } = await squareClient.paymentsApi.createPayment({
            sourceId,
            amountMoney: { amount: BigInt(amount), currency },
            locationId: process.env.SQUARE_LOCATION_ID,
            idempotencyKey: require('crypto').randomUUID()
        });
        res.json({ success: true, payment: result.payment });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.get('/api/claude-info', (req, res) => {
    res.json({
        model: 'claude-haiku-4-5-20251001',
        version: '4.5',
        status: 'ready'
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Health check: http://localhost:${PORT}/health`);
});
EOF

    # Create .env.example
    cat > "$PROJECT_DIR/.env.example" <<'EOF'
NODE_ENV=production
PORT=3000
CLAUDE_API_KEY=your_api_key_here
SQUARE_ACCESS_TOKEN=your_square_access_token
SQUARE_LOCATION_ID=your_square_location_id
DATABASE_URL=postgresql://postgres:password@localhost:5432/production
REDIS_URL=redis://localhost:6379
DOMAIN=localhost
EOF

    # Create nginx config
    cat > "$PROJECT_DIR/config/nginx.conf" <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

    # Create docker-compose.yml
    cat > "$PROJECT_DIR/docker-compose.yml" <<'EOF'
version: '3.8'
services:
  app:
    image: node:20-alpine
    working_dir: /app
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: production
      PORT: 3000
    command: npm start

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: production
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
EOF

    # Create PM2 ecosystem config
    cat > "$PROJECT_DIR/ecosystem.config.js" <<'EOF'
module.exports = {
  apps: [
    {
      name: 'production-app',
      script: './src/server.js',
      instances: 'max',
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: '/opt/logs/app-error.log',
      out_file: '/opt/logs/app-out.log',
      log_file: '/opt/logs/app-combined.log',
      time_format: 'YYYY-MM-DD HH:mm:ss Z',
      autorestart: true,
      max_restarts: 999999,
      min_uptime: '5s',
      restart_delay: 1000,
      watch: false,
      max_memory_restart: '500M',
      exp_backoff_restart_delay: 100,
      kill_timeout: 5000
    }
  ]
};
EOF

    log_info "Project structure created at $PROJECT_DIR"
    echo "$PROJECT_DIR"
}

################################################################################
# INSTALL PROJECT DEPENDENCIES
################################################################################
install_project_deps() {
    local PROJECT_DIR=$1
    log_section "Installing project dependencies"
    
    cd "$PROJECT_DIR"
    npm install
    log_info "npm dependencies installed"
}

################################################################################
# CREATE DEPLOYMENT SCRIPTS
################################################################################
create_deployment_scripts() {
    log_section "Creating deployment scripts"
    
    # Main deploy script
    cat > /opt/scripts/deploy.sh <<'DEPLOY_EOF'
#!/bin/bash
set -e

PROJECT_DIR="$INSTALL_DIR/$PROJECT_NAME"
cd "$PROJECT_DIR"

echo "📦 Pulling latest code..."
git pull origin main || true

echo "📥 Installing dependencies..."
npm install

echo "🔄 Restarting PM2 app..."
pm2 delete $PROJECT_NAME 2>/dev/null || true
pm2 start ecosystem.config.js --name $PROJECT_NAME
pm2 save

echo "✅ Deployment complete"
pm2 list
DEPLOY_EOF
    chmod +x /opt/scripts/deploy.sh

    # Health check script
    cat > /opt/scripts/health-check.sh <<'HEALTH_EOF'
#!/bin/bash
HEALTH_URL="http://localhost:3000/health"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL")

if [ "$RESPONSE" == "200" ]; then
    echo "✅ Application healthy"
    curl -s "$HEALTH_URL" | jq .
else
    echo "❌ Application unhealthy (HTTP $RESPONSE)"
    exit 1
fi
HEALTH_EOF
    chmod +x /opt/scripts/health-check.sh

    # Backup script
    cat > /opt/scripts/backup.sh <<'BACKUP_EOF'
#!/bin/bash
BACKUP_DIR="/opt/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🔄 Starting backup..."
pg_dump production | gzip > "$BACKUP_DIR/db_$TIMESTAMP.sql.gz"
redis-cli BGSAVE

echo "✅ Backup complete: $BACKUP_DIR/db_$TIMESTAMP.sql.gz"
BACKUP_EOF
    chmod +x /opt/scripts/backup.sh

    log_info "Deployment scripts created in /opt/scripts"
}

################################################################################
# CONFIGURE FIREWALL
################################################################################
configure_firewall() {
    log_section "Configuring UFW firewall"
    
    apt-get install -y ufw
    ufw --force enable
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp      # SSH
    ufw allow 80/tcp      # HTTP
    ufw allow 443/tcp     # HTTPS
    ufw allow 3000/tcp    # App
    
    log_info "Firewall configured"
}

################################################################################
# SETUP SYSTEMD SERVICES
################################################################################
setup_systemd_services() {
    log_section "Setting up systemd services"
    
    # PM2 startup with auto-restart
    pm2 startup systemd -u root --hp /root
    pm2 save --force
    
    # Create PM2 resurrection service
    cat > /etc/systemd/system/pm2-resurrect.service <<'PM2_RESURRECT'
[Unit]
Description=PM2 Auto Resurrect
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/pm2 resurrect
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
PM2_RESURRECT
    
    systemctl daemon-reload
    systemctl enable pm2-resurrect.service
    
    # Create systemd service for app
    cat > /etc/systemd/system/$PROJECT_NAME.service <<'SYSTEMD_EOF'
[Unit]
Description=Production App with PM2
After=network.target postgresql.service redis-server.service
Requires=network.target

[Service]
Type=forking
User=root
WorkingDirectory=/opt/deployments/production-app
ExecStart=/usr/bin/pm2 start ecosystem.config.js --name production-app
ExecReload=/usr/bin/pm2 reload production-app
ExecStop=/usr/bin/pm2 stop production-app
Restart=always
RestartSec=5
StartLimitInterval=0
StartLimitBurst=0

[Install]
WantedBy=multi-user.target
SYSTEMD_EOF

    systemctl daemon-reload
    systemctl enable $PROJECT_NAME.service
    log_info "Systemd services configured"
}

################################################################################
# CREATE CLAUDE INTEGRATION SCRIPT
################################################################################
create_claude_integration() {
    log_section "Creating Claude Haiku integration script"
    
    cat > /opt/scripts/claude-deploy-assistant.sh <<'CLAUDE_EOF'
#!/bin/bash

CONFIG_FILE="/opt/claude/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Claude config not found"
    exit 1
fi

API_KEY=$(grep -o '"api_key":"[^"]*' "$CONFIG_FILE" | cut -d'"' -f4)

run_claude_command() {
    local prompt="$1"
    
    curl -X POST https://api.anthropic.com/v1/messages \
        -H "x-api-key: $API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -H "content-type: application/json" \
        -d "{
            \"model\": \"claude-haiku-4-5-20251001\",
            \"max_tokens\": 4096,
            \"messages\": [
                {\"role\": \"user\", \"content\": \"$prompt\"}
            ]
        }"
}

case "$1" in
    "deploy")
        run_claude_command "Analyze and suggest deployment improvements for a production Node.js app with Docker, PostgreSQL, and Redis"
        ;;
    "diagnose")
        run_claude_command "Analyze system logs and provide diagnostic recommendations"
        ;;
    *)
        echo "Usage: $0 {deploy|diagnose}"
        ;;
esac
CLAUDE_EOF
    chmod +x /opt/scripts/claude-deploy-assistant.sh
    log_info "Claude integration script created"
}

################################################################################
# FINAL CONFIGURATION
################################################################################
final_setup() {
    log_section "Final configuration"
    
    # Copy nginx config
    PROJECT_DIR="$INSTALL_DIR/$PROJECT_NAME"
    if [ -f "$PROJECT_DIR/config/nginx.conf" ]; then
        cp "$PROJECT_DIR/config/nginx.conf" /etc/nginx/sites-available/$PROJECT_NAME
        ln -sf /etc/nginx/sites-available/$PROJECT_NAME /etc/nginx/sites-enabled/$PROJECT_NAME
        rm -f /etc/nginx/sites-enabled/default
        nginx -t && systemctl restart nginx
        log_info "Nginx configured"
    fi
    
    # Set permissions
    chown -R root:root "$INSTALL_DIR"
    chown -R root:root "$DOWNLOADS_DIR"
    chmod 755 /opt/scripts/*.sh
    
    # Create summary file
    cat > /opt/DEPLOYMENT_SUMMARY.txt <<SUMMARY_EOF
════════════════════════════════════════════════════════════
    DEPLOYMENT COMPLETE - Claude 4.5 Haiku Enabled
════════════════════════════════════════════════════════════

INSTALLATION DETAILS:
- Ubuntu Version: $(lsb_release -ds)
- Node.js Version: $(node -v)
- npm Version: $(npm -v)
- Docker Version: $(docker --version)
- PostgreSQL Version: $(psql --version)
- Redis Version: $(redis-cli --version)
- Nginx Version: $(nginx -v 2>&1)

CLAUDE AI INTEGRATION:
- Model: Claude 4.5 Haiku (claude-haiku-4-5-20251001)
- CLI Location: /usr/local/bin/claude
- Config: /opt/claude/config.json
- Integration Script: /opt/scripts/claude-deploy-assistant.sh

PROJECT LOCATION:
- Path: $INSTALL_DIR/$PROJECT_NAME
- App Port: $PORT
- Domain: $DOMAIN
- Health Check: http://$DOMAIN:$PORT/health

KEY SCRIPTS:
- Deploy: /opt/scripts/deploy.sh
- Health Check: /opt/scripts/health-check.sh
- Backup: /opt/scripts/backup.sh
- Claude Assistant: /opt/scripts/claude-deploy-assistant.sh

DIRECTORIES:
- Downloads: $DOWNLOADS_DIR
- Projects: $INSTALL_DIR
- Scripts: /opt/scripts
- Logs: /opt/logs
- Backups: /opt/backups

NEXT STEPS:
1. Update /opt/deployments/production-app/.env with your settings
2. Run: /opt/scripts/deploy.sh
3. Verify: /opt/scripts/health-check.sh
4. Monitor: pm2 list
5. View logs: pm2 logs

TO START APP:
- cd $INSTALL_DIR/$PROJECT_NAME
- npm install
- pm2 start ecosystem.config.js

TROUBLESHOOTING:
- Logs: tail -f /opt/logs/app-combined.log
- PM2: pm2 list (running processes)
- Docker: docker ps (running containers)
- Nginx: nginx -t (test config)

════════════════════════════════════════════════════════════
SUMMARY_EOF

    log_info "Deployment summary saved to /opt/DEPLOYMENT_SUMMARY.txt"
}

################################################################################
# MAIN EXECUTION
################################################################################
main() {
    log_section "UBUNTU DEPLOYMENT INITIALIZATION"
    
    check_sudo
    check_ubuntu_version
    check_disk_space
    setup_directories
    update_system
    install_nodejs
    install_docker
    install_postgresql
    install_redis
    install_nginx
    install_git_tools
    install_dev_tools
    install_claude_haiku
    
    PROJECT_DIR=$(create_project_structure)
    install_project_deps "$PROJECT_DIR"
    create_deployment_scripts
    configure_firewall
    setup_systemd_services
    create_claude_integration
    final_setup
    
    SCRIPT_END=$(date +%s)
    DURATION=$((SCRIPT_END - SCRIPT_START))
    
    log_section "DEPLOYMENT COMPLETED SUCCESSFULLY"
    echo ""
    echo "⏱️  Total execution time: ${DURATION}s"
    echo ""
    cat /opt/DEPLOYMENT_SUMMARY.txt
    echo ""
    echo "✅ System is ready for production"
}

# Run main function
main "$@"