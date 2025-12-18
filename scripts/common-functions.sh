#!/bin/bash
# AMP-OS Common Functions
# Shared utilities for installation and update scripts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Get AMP-OS home directory
get_amp_os_home() {
    # Check environment variable first, then common locations
    if [[ -n "${AMP_OS_HOME:-}" ]]; then
        echo "$AMP_OS_HOME"
    elif [[ -d "$HOME/Development/Amp-OS" ]]; then
        echo "$HOME/Development/Amp-OS"
    elif [[ -d "$HOME/Amp-OS" ]]; then
        echo "$HOME/Amp-OS"
    else
        # Default to script location's parent
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        echo "$(dirname "$script_dir")"
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Read YAML value (simple parser for single-line values)
read_yaml_value() {
    local file="$1"
    local key="$2"
    grep "^${key}:" "$file" 2>/dev/null | sed "s/^${key}:[[:space:]]*//" | tr -d "'" | tr -d '"'
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    fi
}

# Create symlink or copy based on config (idempotent and safe)
link_or_copy() {
    local source="$1"
    local dest="$2"
    local use_symlinks="${3:-true}"
    
    # Check if destination already exists
    if [[ -L "$dest" ]]; then
        # It's a symlink - check if it points to the right place
        local current_target
        current_target="$(readlink "$dest" 2>/dev/null || true)"
        
        if [[ "$use_symlinks" == "true" ]] && [[ "$current_target" == "$source" ]]; then
            log_info "Already linked: $dest -> $source (skipped)"
            return 0
        fi
        
        # Wrong target or switching to copy mode - remove it
        rm -f "$dest"
        log_info "Removed stale symlink: $dest"
        
    elif [[ -e "$dest" ]]; then
        # It's a real file/directory - back it up before replacing
        local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$dest" "$backup"
        log_warning "Backed up existing: $dest -> $backup"
    fi
    
    if [[ "$use_symlinks" == "true" ]]; then
        ln -s "$source" "$dest"
        log_info "Symlinked: $dest -> $source"
    else
        cp -r "$source" "$dest"
        log_info "Copied: $source -> $dest"
    fi
}

# Get list of skills to install based on config
get_skills_to_install() {
    local config_file="$1"
    local profile_dir="$2"
    local skills=""
    
    # Phase skills
    if [[ "$(read_yaml_value "$config_file" "install_phase_skills")" != "false" ]]; then
        skills="$skills plan-product shape-spec write-spec create-tasks implement-tasks verify-implementation"
    fi
    
    # Verifier skills
    if [[ "$(read_yaml_value "$config_file" "install_verifier_skills")" != "false" ]]; then
        skills="$skills spec-verifier implementation-verifier"
    fi
    
    # Standards skills
    if [[ "$(read_yaml_value "$config_file" "install_standards_skills")" != "false" ]]; then
        skills="$skills standards-global standards-backend standards-frontend standards-testing"
    fi
    
    # Utility skills
    if [[ "$(read_yaml_value "$config_file" "install_utility_skills")" != "false" ]]; then
        skills="$skills architecture-diagrams code-analysis"
    fi
    
    echo "$skills"
}

# Validate that AMP-OS is properly installed
validate_amp_os_install() {
    local amp_os_home
    amp_os_home="$(get_amp_os_home)"
    
    if [[ ! -d "$amp_os_home" ]]; then
        log_error "AMP-OS not found at $amp_os_home"
        return 1
    fi
    
    if [[ ! -f "$amp_os_home/config.yml" ]]; then
        log_error "config.yml not found in $amp_os_home"
        return 1
    fi
    
    if [[ ! -d "$amp_os_home/profiles/default/skills" ]]; then
        log_error "Default profile skills not found"
        return 1
    fi
    
    return 0
}
