#!/bin/bash
# install.sh - Universal installation script for Linux and Termux

set -e

echo "🌦️  Cyberzilla Weather System Installer"
echo "========================================"
echo ""

# Detect platform
if [ -n "$TERMUX_VERSION" ]; then
    PLATFORM="termux"
    echo "📱 Detected: Termux (Android)"
else
    PLATFORM="linux"
    echo "🐧 Detected: Linux"
fi

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Go is installed
check_go() {
    if ! command -v go &> /dev/null; then
        echo -e "${YELLOW}Go is not installed. Installing...${NC}"
        if [ "$PLATFORM" = "termux" ]; then
            pkg install golang -y
        else
            echo -e "${RED}Please install Go 1.21 or higher from https://golang.org/dl/${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ Go is installed: $(go version)${NC}"
    fi
}

# Check if SQLite is installed
check_sqlite() {
    if [ "$PLATFORM" = "termux" ]; then
        if ! pkg list-installed | grep -q "sqlite"; then
            echo -e "${YELLOW}SQLite not installed. Installing...${NC}"
            pkg install sqlite -y
        fi
    fi
    echo -e "${GREEN}✓ SQLite is ready${NC}"
}

# Create directory structure
create_directories() {
    echo "📁 Creating directory structure..."
    mkdir -p static
    mkdir -p data
    mkdir -p logs
    echo -e "${GREEN}✓ Directories created${NC}"
}

# Download or create config file
setup_config() {
    if [ ! -f "config.yaml" ]; then
        echo "⚙️  Creating configuration file..."
        cat > config.yaml << 'EOF'
server:
  port: 8080
  host: "0.0.0.0"
  mode: "release"

api:
  weather_api_key: "f807e87175ee4ff98f551941252009"
  timeout: 10
  max_retries: 3

security:
  encryption_key: "cyberzilla-systems-key-32bit"
  cors_origins:
    - "*"
  rate_limit: 100

cache:
  duration_minutes: 15
  cleanup_interval_minutes: 5
  max_entries: 1000

database:
  path: "./weather_cache.db"
  max_connections: 10

logging:
  level: "info"
  file: "weather-app.log"
  max_size_mb: 10

admin:
  email: "cyberzilla.systems@gmail.com"
  contact_url: "mailto:cyberzilla.systems@gmail.com"

features:
  enable_prayer_times: true
  enable_hunt_times: true
  enable_air_quality: true
  enable_astronomy: true
  enable_alerts: true
  enable_ip_lookup: true
EOF
        echo -e "${GREEN}✓ Configuration file created${NC}"
    fi
}

# Setup environment variables
setup_env() {
    if [ ! -f ".env" ]; then
        echo "🔐 Creating environment file..."
        cat > .env << 'EOF'
PORT=8080
WEATHER_API_KEY=f807e87175ee4ff98f551941252009
ENCRYPTION_KEY=cyberzilla-systems-key-32bit
ADMIN_EMAIL=cyberzilla.systems@gmail.com
LOG_LEVEL=info
CACHE_DURATION_MINUTES=15
EOF
        echo -e "${GREEN}✓ Environment file created${NC}"
    fi
}

# Build the application
build_app() {
    echo "🔨 Building application..."
    
    # Initialize go.mod if it doesn't exist
    if [ ! -f "go.mod" ]; then
        go mod init github.com/cyberzilla/weather-app
    fi
    
    # Download dependencies
    echo "📦 Downloading dependencies..."
    go get github.com/gin-contrib/cors@latest
    go get github.com/gin-gonic/gin@latest
    go get github.com/mattn/go-sqlite3@latest
    go mod tidy
    
    # Build
    echo "⚡ Compiling..."
    CGO_ENABLED=1 go build -o weather-app main.go
    
    if [ -f "weather-app" ]; then
        chmod +x weather-app
        echo -e "${GREEN}✓ Build successful!${NC}"
    else
        echo -e "${RED}✗ Build failed${NC}"
        exit 1
    fi
}

# Create systemd service (Linux only)
create_service() {
    if [ "$PLATFORM" = "linux" ] && [ "$EUID" -eq 0 ]; then
        echo "🔧 Creating systemd service..."
        cat > /etc/systemd/system/weather-app.service << EOF
[Unit]
Description=Cyberzilla Weather System
After=network.target

[Service]
Type=simple
User=$SUDO_USER
WorkingDirectory=$(pwd)
ExecStart=$(pwd)/weather-app
Restart=always
RestartSec=10
Environment="PATH=/usr/local/go/bin:/usr/bin"

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        echo -e "${GREEN}✓ Systemd service created${NC}"
        echo "  To start: sudo systemctl start weather-app"
        echo "  To enable on boot: sudo systemctl enable weather-app"
    fi
}

# Create start script
create_start_script() {
    echo "📝 Creating start script..."
    cat > start.sh << 'EOF'
#!/bin/bash
# Start script for Cyberzilla Weather System

# Source environment variables
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Set locale for UTF-8 support (important for Persian)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "🌦️  Starting Cyberzilla Weather System..."
echo "📧 Admin: cyberzilla.systems@gmail.com"
echo ""

# Start the application
./weather-app
EOF
    chmod +x start.sh
    echo -e "${GREEN}✓ Start script created${NC}"
}

# Main installation process
main() {
    echo ""
    echo "Starting installation..."
    echo ""
    
    check_go
    check_sqlite
    create_directories
    setup_config
    setup_env
    build_app
    create_start_script
    
    if [ "$PLATFORM" = "linux" ]; then
        if [ "$EUID" -eq 0 ]; then
            create_service
        fi
    fi
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Installation Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "To start the application:"
    echo "  ./start.sh"
    echo ""
    echo "Or run directly:"
    echo "  ./weather-app"
    echo ""
    echo "Then open your browser to:"
    echo "  http://localhost:8080"
    echo ""
    echo "📧 Support: cyberzilla.systems@gmail.com"
    echo ""
}

# Run main installation
main

---
#!/bin/bash
# deploy.sh - Production deployment script

set -e

echo "🚀 Cyberzilla Weather System - Production Deployment"
echo "===================================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
APP_NAME="weather-app"
DEPLOY_USER="weather"
DEPLOY_DIR="/opt/cyberzilla-weather"
SERVICE_NAME="weather-app"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (sudo ./deploy.sh)${NC}"
    exit 1
fi

# Create deployment user
create_user() {
    if ! id "$DEPLOY_USER" &>/dev/null; then
        echo "👤 Creating deployment user..."
        useradd -r -s /bin/bash -d "$DEPLOY_DIR" "$DEPLOY_USER"
        echo -e "${GREEN}✓ User created${NC}"
    else
        echo -e "${GREEN}✓ User already exists${NC}"
    fi
}

# Create directories
setup_directories() {
    echo "📁 Setting up directories..."
    mkdir -p "$DEPLOY_DIR"/{static,data,logs,backup}
    chown -R "$DEPLOY_USER:$DEPLOY_USER" "$DEPLOY_DIR"
    echo -e "${GREEN}✓ Directories ready${NC}"
}

# Copy files
deploy_files() {
    echo "📦 Deploying application files..."
    
    # Copy binary
    cp weather-app "$DEPLOY_DIR/"
    
    # Copy static files
    cp -r static/* "$DEPLOY_DIR/static/" 2>/dev/null || true
    
    # Copy config
    cp config.yaml "$DEPLOY_DIR/"
    
    # Set permissions
    chown -R "$DEPLOY_USER:$DEPLOY_USER" "$DEPLOY_DIR"
    chmod +x "$DEPLOY_DIR/weather-app"
    
    echo -e "${GREEN}✓ Files deployed${NC}"
}

# Setup systemd service
setup_service() {
    echo "🔧 Configuring systemd service..."
    
    cat > /etc/systemd/system/${SERVICE_NAME}.service << EOF
[Unit]
Description=Cyberzilla Weather System
Documentation=https://github.com/cyberzilla/weather-app
After=network.target

[Service]
Type=simple
User=$DEPLOY_USER
Group=$DEPLOY_USER
WorkingDirectory=$DEPLOY_DIR
ExecStart=$DEPLOY_DIR/weather-app
Restart=always
RestartSec=10

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$DEPLOY_DIR/data $DEPLOY_DIR/logs

# Environment
Environment="PATH=/usr/local/bin:/usr/bin"
Environment="LANG=en_US.UTF-8"
Environment="LC_ALL=en_US.UTF-8"

# Logging
StandardOutput=append:$DEPLOY_DIR/logs/app.log
StandardError=append:$DEPLOY_DIR/logs/error.log

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    echo -e "${GREEN}✓ Service configured${NC}"
}

# Setup nginx reverse proxy
setup_nginx() {
    if command -v nginx &> /dev/null; then
        echo "🌐 Configuring Nginx..."
        
        cat > /etc/nginx/sites-available/weather-app << 'EOF'
server {
    listen 80;
    server_name weather.cyberzilla.systems;  # Change to your domain

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOF

        ln -sf /etc/nginx/sites-available/weather-app /etc/nginx/sites-enabled/
        nginx -t && systemctl reload nginx
        echo -e "${GREEN}✓ Nginx configured${NC}"
    fi
}

# Setup firewall
setup_firewall() {
    if command -v ufw &> /dev/null; then
        echo "🔥 Configuring firewall..."
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw allow 8080/tcp
        echo -e "${GREEN}✓ Firewall configured${NC}"
    fi
}

# Setup log rotation
setup_logrotate() {
    echo "📋 Setting up log rotation..."
    
    cat > /etc/logrotate.d/weather-app << EOF
$DEPLOY_DIR/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 $DEPLOY_USER $DEPLOY_USER
    sharedscripts
    postrotate
        systemctl reload $SERVICE_NAME > /dev/null 2>&1 || true
    endscript
}
EOF

    echo -e "${GREEN}✓ Log rotation configured${NC}"
}

# Create backup script
create_backup_script() {
    echo "💾 Creating backup script..."
    
    cat > "$DEPLOY_DIR/backup.sh" << 'EOF'
#!/bin/bash
# Backup script for Cyberzilla Weather System

BACKUP_DIR="/opt/cyberzilla-weather/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="weather_backup_$DATE.tar.gz"

echo "Creating backup: $BACKUP_FILE"

tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    --exclude='backup' \
    -C /opt/cyberzilla-weather .

# Keep only last 7 backups
cd "$BACKUP_DIR"
ls -t weather_backup_*.tar.gz | tail -n +8 | xargs -r rm

echo "Backup complete: $BACKUP_FILE"
EOF

    chmod +x "$DEPLOY_DIR/backup.sh"
    chown "$DEPLOY_USER:$DEPLOY_USER" "$DEPLOY_DIR/backup.sh"
    
    # Add to crontab (daily backup at 2 AM)
    (crontab -u "$DEPLOY_USER" -l 2>/dev/null; echo "0 2 * * * $DEPLOY_DIR/backup.sh") | crontab -u "$DEPLOY_USER" -
    
    echo -e "${GREEN}✓ Backup script created${NC}"
}

# Setup monitoring
setup_monitoring() {
    echo "📊 Setting up monitoring..."
    
    cat > "$DEPLOY_DIR/monitor.sh" << 'EOF'
#!/bin/bash
# Simple monitoring script

SERVICE="weather-app"
EMAIL="cyberzilla.systems@gmail.com"

if ! systemctl is-active --quiet $SERVICE; then
    echo "⚠️  $SERVICE is down! Attempting restart..." | mail -s "Weather App Alert" $EMAIL
    systemctl restart $SERVICE
fi
EOF

    chmod +x "$DEPLOY_DIR/monitor.sh"
    
    # Add to crontab (check every 5 minutes)
    (crontab -l 2>/dev/null; echo "*/5 * * * * $DEPLOY_DIR/monitor.sh") | crontab -
    
    echo -e "${GREEN}✓ Monitoring configured${NC}"
}

# Start service
start_service() {
    echo "▶️  Starting service..."
    systemctl enable "$SERVICE_NAME"
    systemctl start "$SERVICE_NAME"
    
    sleep 2
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${GREEN}✓ Service is running${NC}"
    else
        echo -e "${RED}✗ Service failed to start${NC}"
        echo "Check logs: journalctl -u $SERVICE_NAME -n 50"
        exit 1
    fi
}

# Show status
show_status() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Deployment Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Service Status:"
    systemctl status "$SERVICE_NAME" --no-pager -l
    echo ""
    echo "Application URL: http://localhost:8080"
    echo "Service Control:"
    echo "  Start:   sudo systemctl start $SERVICE_NAME"
    echo "  Stop:    sudo systemctl stop $SERVICE_NAME"
    echo "  Restart: sudo systemctl restart $SERVICE_NAME"
    echo "  Status:  sudo systemctl status $SERVICE_NAME"
    echo "  Logs:    sudo journalctl -u $SERVICE_NAME -f"
    echo ""
    echo "Backup: $DEPLOY_DIR/backup.sh"
    echo "Config: $DEPLOY_DIR/config.yaml"
    echo ""
    echo "📧 Support: cyberzilla.systems@gmail.com"
    echo ""
}

# Main deployment
main() {
    echo ""
    
    create_user
    setup_directories
    deploy_files
    setup_service
    setup_nginx
    setup_firewall
    setup_logrotate
    create_backup_script
    setup_monitoring
    start_service
    show_status
}

# Run deployment
main

---
#!/bin/bash
# termux-install.sh - Specialized Termux installation script

echo "📱 Cyberzilla Weather System - Termux Installation"
echo "=================================================="
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Update packages
echo "📦 Updating packages..."
pkg update -y
pkg upgrade -y

# Install required packages
echo "📥 Installing dependencies..."
pkg install -y \
    golang \
    git \
    sqlite \
    termux-api \
    wget \
    curl

# Set up UTF-8 locale for Persian support
echo "🌐 Configuring UTF-8 locale..."
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Add to .bashrc for persistence
if ! grep -q "LANG=en_US.UTF-8" ~/.bashrc; then
    echo "export LANG=en_US.UTF-8" >> ~/.bashrc
    echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
fi

# Create project directory
PROJECT_DIR="$HOME/weather-app"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Initialize Go module
echo "🔧 Setting up Go project..."
go mod init github.com/cyberzilla/weather-app

# Download dependencies
echo "📚 Downloading Go dependencies..."
go get github.com/gin-contrib/cors@latest
go get github.com/gin-gonic/gin@latest
go get github.com/mattn/go-sqlite3@latest
go mod tidy

# Create directories
mkdir -p static data logs

# Build application
echo "🔨 Building application..."
CGO_ENABLED=1 go build -o weather-app main.go

if [ -f "weather-app" ]; then
    chmod +x weather-app
    echo -e "${GREEN}✓ Build successful!${NC}"
else
    echo "✗ Build failed"
    exit 1
fi

# Create start script
cat > start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
cd ~/weather-app
./weather-app
EOF
chmod +x start.sh

# Create shortcut script
cat > ~/weather << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/weather-app
./start.sh
EOF
chmod +x ~/weather

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "🎉 Termux installation successful!"
echo ""
echo "To start the application:"
echo "  cd ~/weather-app"
echo "  ./start.sh"
echo ""
echo "Or simply type:"
echo "  ~/weather"
echo ""
echo "Then open your browser to:"
echo "  http://localhost:8080"
echo ""
echo "💡 Tip: For Persian text to display correctly,"
echo "   make sure you're using a terminal with UTF-8 support"
echo ""
echo "📧 Support: cyberzilla.systems@gmail.com"
echo ""

---
#!/bin/bash
# update.sh - Update script for the weather application

echo "🔄 Updating Cyberzilla Weather System..."

# Detect platform
if [ -n "$TERMUX_VERSION" ]; then
    DEPLOY_DIR="$HOME/weather-app"
else
    DEPLOY_DIR="/opt/cyberzilla-weather"
fi

# Backup current version
echo "💾 Creating backup..."
if [ -f "$DEPLOY_DIR/weather-app" ]; then
    cp "$DEPLOY_DIR/weather-app" "$DEPLOY_DIR/weather-app.backup"
    echo "✓ Backup created"
fi

# Rebuild
echo "🔨 Rebuilding application..."
cd "$DEPLOY_DIR"

# Pull latest code (if using git)
if [ -d ".git" ]; then
    git pull origin main
fi

# Rebuild
go build -o weather-app main.go

# Restart service (Linux only)
if [ -z "$TERMUX_VERSION" ] && command -v systemctl &> /dev/null; then
    echo "🔄 Restarting service..."
    sudo systemctl restart weather-app
fi

echo ""
echo "✓ Update complete!"
echo ""

---
# uninstall.sh - Uninstallation script

#!/bin/bash
echo "🗑️  Uninstalling Cyberzilla Weather System..."

read -p "Are you sure you want to uninstall? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Detect platform
if [ -n "$TERMUX_VERSION" ]; then
    DEPLOY_DIR="$HOME/weather-app"
    rm -rf "$DEPLOY_DIR"
    rm -f ~/weather
    echo "✓ Uninstalled from Termux"
else
    # Linux
    if [ "$EUID" -eq 0 ]; then
        systemctl stop weather-app 2>/dev/null
        systemctl disable weather-app 2>/dev/null
        rm -f /etc/systemd/system/weather-app.service
        systemctl daemon-reload
        rm -rf /opt/cyberzilla-weather
        userdel weather 2>/dev/null
        echo "✓ Uninstalled from Linux"
    else
        echo "Please run with sudo for complete removal"
        rm -rf ./weather-app ./weather_cache.db ./weather-app.log
    fi
fi

echo ""
echo "✓ Cyberzilla Weather System has been uninstalled"
echo "Thank you for using our application!"
echo ""
