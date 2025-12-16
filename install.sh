#!/bin/bash
# AMP-OS Installer
# One-line install: curl -fsSL https://raw.githubusercontent.com/korallis/Amp-OS/main/install.sh | bash

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REPO="korallis/Amp-OS"
INSTALL_DIR="${AMP_OS_HOME:-$HOME/Amp-OS}"
BRANCH="${AMP_OS_BRANCH:-main}"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Check for required tools
check_requirements() {
    if ! command -v git &> /dev/null; then
        log_error "git is required but not installed"
        exit 1
    fi
}

# Main installation
install_amp_os() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║         AMP-OS Installer              ║"
    echo "║   Spec-driven workflows for Amp CLI   ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
    
    check_requirements
    
    log_info "Installing to: $INSTALL_DIR"
    
    # Check if already installed
    if [[ -d "$INSTALL_DIR" ]]; then
        log_info "AMP-OS already exists at $INSTALL_DIR"
        read -p "Update existing installation? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Updating..."
            cd "$INSTALL_DIR"
            git pull origin "$BRANCH"
            log_success "Updated successfully!"
        else
            log_info "Cancelled"
            exit 0
        fi
    else
        # Clone repository
        log_info "Cloning repository..."
        git clone --depth 1 --branch "$BRANCH" "https://github.com/$REPO.git" "$INSTALL_DIR"
        
        # Make scripts executable
        chmod +x "$INSTALL_DIR/scripts/"*.sh
        
        log_success "Installation complete!"
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "AMP-OS installed to: $INSTALL_DIR"
    echo ""
    echo "To add a project, run:"
    echo "  $INSTALL_DIR/scripts/amp-project-install.sh /path/to/project"
    echo ""
    echo "Or add to PATH for easier access:"
    echo "  export PATH=\"\$PATH:$INSTALL_DIR/scripts\""
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

install_amp_os
