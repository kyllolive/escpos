#!/bin/bash

LOGFILE="install_log.txt"
echo "Installation Log - $(date)" > "$LOGFILE"

# Function to log messages to both console and log file
log() {
    echo "$1" | tee -a "$LOGFILE"
}

log "Checking if Node.js is installed..."
if ! command -v node &> /dev/null; then
    log "Node.js is not installed. Attempting to install Node.js..."

    # Attempt to download and install Node.js
    NODE_VERSION="v18.17.1"
    NODE_DIST="node-$NODE_VERSION-linux-x64.tar.xz"
    NODE_URL="https://nodejs.org/dist/$NODE_VERSION/$NODE_DIST"
    
    log "Downloading Node.js from $NODE_URL..."
    if curl -o "$NODE_DIST" "$NODE_URL"; then
        log "Extracting Node.js..."
        tar -xf "$NODE_DIST"
        
        log "Installing Node.js..."
        sudo cp -r "node-$NODE_VERSION-linux-x64/"* /usr/local/
        
        # Cleanup
        rm -rf "$NODE_DIST" "node-$NODE_VERSION-linux-x64"
        log "Node.js installed successfully."
    else
        log "Failed to download Node.js. Exiting."
        exit 1
    fi
else
    log "Node.js is already installed."
fi

# Verify Node.js installation
if ! command -v node &> /dev/null; then
    log "Node.js installation failed. Exiting script."
    exit 1
else
    log "Node.js installation verified: $(node -v)"
fi

# Navigate to the app directory
APP_DIR="$(dirname "$0")"
log "Navigating to the application directory: $APP_DIR"
cd "$APP_DIR" || exit 1

# Install dependencies
log "Installing application dependencies with npm..."
if npm install >> "$LOGFILE" 2>&1; then
    log "Dependencies installed."
else
    log "Failed to install dependencies."
    exit 1
fi

# Build the application
log "Building the application..."
if npm run build >> "$LOGFILE" 2>&1; then
    log "Application built successfully."
else
    log "Failed to build the application."
    exit 1
fi

# Install pm2 globally
log "Installing pm2 globally..."
if npm install -g pm2 >> "$LOGFILE" 2>&1; then
    log "PM2 installed."
else
    log "Failed to install PM2."
    exit 1
fi

# Start the app with PM2
log "Starting the printer-server with PM2..."
if pm2 start dist/src/index.js --name "printer-server" >> "$LOGFILE" 2>&1; then
    log "Printer-server started with PM2."
else
    log "Failed to start printer-server with PM2."
    exit 1
fi

# Save PM2 process list and set up startup
log "Saving PM2 process list..."
pm2 save >> "$LOGFILE" 2>&1

log "Setting up PM2 to start on boot..."
pm2 startup >> "$LOGFILE" 2>&1
eval $(pm2 startup | tail -n 1) >> "$LOGFILE" 2>&1

# Start the app immediately
log "Starting the app immediately..."
pm2 start printer-server >> "$LOGFILE" 2>&1

log "Script execution completed successfully. Check $LOGFILE for details."
