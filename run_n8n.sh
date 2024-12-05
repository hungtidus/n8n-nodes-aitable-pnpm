#!/bin/bash

# Enable error handling
set -e

# Function for error logging
log_error() {
    echo "ERROR: \$1" >&2
}

# Function for info logging
log_info() {
    echo "INFO: $1"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up..."
    cd ~/.n8n/custom 2>/dev/null || true
}

# Set trap for cleanup
trap cleanup EXIT

# Step 1: Navigate to n8n custom directory
log_info "Navigating to n8n custom directory..."
cd ~/.n8n/custom || {
    log_error "Failed to access ~/.n8n/custom directory"
    exit 1
}

# Step 2: Unlink existing package
log_info "Unlinking existing package..."
pnpm unlink n8n-nodes-aitable || {
    log_info "No existing link found - continuing..."
}

# Step 3: Navigate to project directory
log_info "Navigating to project directory..."
cd ~/n8n-nodes-starter || {
    log_error "Failed to access ~/n8n-nodes-starter directory"
    exit 1
}

# Step 4: Clean project
log_info "Cleaning project..."
rm -rf dist node_modules package-lock.json pnpm-lock.yaml

# Step 5: Install dependencies
log_info "Installing dependencies..."
pnpm install || {
    log_error "Failed to install dependencies"
    exit 1
}

# Step 6: Build project
log_info "Building project..."
pnpm run build || {
    log_error "Build failed"
    exit 1
}

# Step 7: Create global link
log_info "Creating global link..."
pnpm link --global || {
    log_error "Failed to create global link"
    exit 1
}

# Step 8: Return to n8n custom directory
log_info "Returning to n8n custom directory..."
cd ~/.n8n/custom || {
    log_error "Failed to access ~/.n8n/custom directory"
    exit 1
}

# Step 9: Link package in n8n custom directory
log_info "Linking package in n8n..."
pnpm link --global n8n-nodes-aitable || {
    log_error "Failed to link package in n8n"
    exit 1
}

# Step 10: Start n8n
log_info "Starting n8n..."
n8n start || {
    log_error "Failed to start n8n"
    exit 1
}
