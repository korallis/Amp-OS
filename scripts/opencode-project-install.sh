#!/bin/bash
# OpenCode-OS Project Installation Script
# Installs spec-driven development workflow for OpenCode
# Requires: oh-my-opencode plugin

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

# Default values
PROJECT_DIR=""
PROFILE="opencode"
USE_SYMLINKS="true"
PROJECT_NAME=""
SKIP_OMO_CHECK="false"
OMO_INSTALLED="false"

# oh-my-opencode installation URL
OMO_REPO="https://github.com/code-yeongyu/oh-my-opencode"

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <project-directory>

Install OpenCode-OS (spec-driven development) into a project.

REQUIREMENTS:
  - OpenCode CLI installed (https://opencode.ai/docs)
  - oh-my-opencode plugin installed ($OMO_REPO)

Options:
    -p, --profile PROFILE    Profile to use (default: opencode)
    -c, --copy               Copy files instead of symlinking
    -n, --name NAME          Project name (default: directory name)
    --skip-omo-check         Skip oh-my-opencode verification
    -h, --help               Show this help message

Examples:
    $(basename "$0") /path/to/my-project
    $(basename "$0") --copy /path/to/my-project
    $(basename "$0") -n "My App" .

EOF
    exit 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--profile)
                PROFILE="$2"
                shift 2
                ;;
            -c|--copy)
                USE_SYMLINKS="false"
                shift
                ;;
            -n|--name)
                PROJECT_NAME="$2"
                shift 2
                ;;
            --skip-omo-check)
                SKIP_OMO_CHECK="true"
                shift
                ;;
            -h|--help)
                usage
                ;;
            -*)
                log_error "Unknown option: $1"
                usage
                ;;
            *)
                PROJECT_DIR="$1"
                shift
                ;;
        esac
    done
    
    if [[ -z "$PROJECT_DIR" ]]; then
        log_error "Project directory is required"
        usage
    fi
    
    # Convert to absolute path
    PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || {
        log_error "Project directory does not exist: $PROJECT_DIR"
        exit 1
    }
    
    # Default project name to directory name
    if [[ -z "$PROJECT_NAME" ]]; then
        PROJECT_NAME="$(basename "$PROJECT_DIR")"
    fi
}

# Check if OpenCode is installed
check_opencode() {
    if ! command_exists opencode; then
        log_error "OpenCode is not installed"
        echo ""
        echo "Install OpenCode first:"
        echo "  curl -fsSL https://opencode.ai/install | bash"
        echo ""
        echo "Or see: https://opencode.ai/docs"
        return 1
    fi
    
    local version
    version=$(opencode --version 2>/dev/null || echo "unknown")
    log_info "OpenCode detected: $version"
    return 0
}

# Check if oh-my-opencode plugin is installed (optional but recommended)
check_oh_my_opencode() {
    if [[ "$SKIP_OMO_CHECK" == "true" ]]; then
        log_warning "Skipping oh-my-opencode check (--skip-omo-check)"
        OMO_INSTALLED="false"
        return 0
    fi
    
    local config_json="$HOME/.config/opencode/opencode.json"
    local config_jsonc="$HOME/.config/opencode/opencode.jsonc"
    OMO_INSTALLED="false"
    
    # Check JSON config (use jq if available for reliable parsing)
    if [[ -f "$config_json" ]]; then
        if command_exists jq; then
            if jq -e '.plugin | index("oh-my-opencode")' "$config_json" >/dev/null 2>&1; then
                OMO_INSTALLED="true"
            fi
        elif grep -q '"oh-my-opencode"' "$config_json" 2>/dev/null; then
            OMO_INSTALLED="true"
        fi
    fi
    
    # Check JSONC config
    if [[ "$OMO_INSTALLED" != "true" ]] && [[ -f "$config_jsonc" ]]; then
        if grep -q '"oh-my-opencode"' "$config_jsonc" 2>/dev/null; then
            OMO_INSTALLED="true"
        fi
    fi
    
    if [[ "$OMO_INSTALLED" == "true" ]]; then
        log_success "oh-my-opencode plugin detected"
    else
        log_warning "oh-my-opencode plugin NOT detected"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo -e "  ${YELLOW}oh-my-opencode is RECOMMENDED for full functionality${NC}"
        echo ""
        echo "  Without it, you'll have LIMITED features:"
        echo "    ✗ No @oracle, @librarian, @explore agents"
        echo "    ✗ No background task orchestration"
        echo "    ✗ No LSP/AST-aware tools"
        echo "    ✗ No todo enforcement"
        echo ""
        echo "  Basic workflow commands will still work."
        echo ""
        echo "  To install (recommended):"
        echo "    1. Add to ~/.config/opencode/opencode.json:"
        echo '       { "plugin": ["oh-my-opencode"] }'
        echo "    2. Run 'opencode' to initialize"
        echo ""
        echo "  Ref: $OMO_REPO"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    fi
    
    return 0
}

# Install oh-my-opencode if user wants
offer_omo_install() {
    echo ""
    read -p "Would you like to install oh-my-opencode now? [y/N] " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Setting up oh-my-opencode..."
        
        # Ensure config directory exists
        mkdir -p "$HOME/.config/opencode"
        
        local config_file="$HOME/.config/opencode/opencode.json"
        
        if [[ -f "$config_file" ]]; then
            # Add to existing config
            if command_exists jq; then
                jq '.plugin = ((.plugin // []) + ["oh-my-opencode"] | unique)' \
                    "$config_file" > /tmp/oc.json && mv /tmp/oc.json "$config_file"
                log_success "Added oh-my-opencode to existing config"
            else
                log_warning "jq not found. Please manually add \"oh-my-opencode\" to plugins in:"
                echo "  $config_file"
                return 1
            fi
        else
            # Create new config
            echo '{"plugin":["oh-my-opencode"]}' > "$config_file"
            log_success "Created config with oh-my-opencode"
        fi
        
        echo ""
        log_info "oh-my-opencode will initialize on next 'opencode' run"
        log_info "You may be prompted to configure model providers"
        echo ""
        
        return 0
    else
        log_info "Skipping oh-my-opencode installation"
        log_warning "OpenCode-OS requires oh-my-opencode for full functionality"
        return 1
    fi
}

# Main installation function
install_opencode_os() {
    local os_home
    os_home="$(get_amp_os_home)"
    
    log_info "Installing OpenCode-OS into: $PROJECT_DIR"
    log_info "Profile: $PROFILE"
    log_info "Project Name: $PROJECT_NAME"
    log_info "Use Symlinks: $USE_SYMLINKS"
    
    local profile_dir="$os_home/profiles/$PROFILE"
    if [[ ! -d "$profile_dir" ]]; then
        log_error "Profile not found: $PROFILE"
        log_info "Available profiles:"
        ls -1 "$os_home/profiles/" 2>/dev/null || echo "  (none)"
        exit 1
    fi
    
    # Create project directories
    log_info "Creating project structure..."
    ensure_dir "$PROJECT_DIR/.opencode/command"
    ensure_dir "$PROJECT_DIR/.claude/rules"
    ensure_dir "$PROJECT_DIR/opencode-os/product"
    ensure_dir "$PROJECT_DIR/opencode-os/specs"
    ensure_dir "$PROJECT_DIR/opencode-os/templates"
    ensure_dir "$PROJECT_DIR/opencode-os/standards"
    
    # Install commands
    log_info "Installing workflow commands..."
    if [[ -d "$profile_dir/commands" ]]; then
        for cmd in "$profile_dir/commands"/*.md; do
            if [[ -f "$cmd" ]]; then
                local cmd_name
                cmd_name="$(basename "$cmd")"
                link_or_copy "$cmd" "$PROJECT_DIR/.opencode/command/$cmd_name" "$USE_SYMLINKS"
            fi
        done
    fi
    
    # Install standards (always copy for editability)
    log_info "Installing standards..."
    if [[ -d "$profile_dir/standards" ]]; then
        for std in "$profile_dir/standards"/*.md; do
            if [[ -f "$std" ]]; then
                cp "$std" "$PROJECT_DIR/opencode-os/standards/"
            fi
        done
    fi
    
    # Install templates (always copy)
    log_info "Installing templates..."
    if [[ -d "$profile_dir/templates" ]]; then
        for tmpl in "$profile_dir/templates"/*.md; do
            if [[ -f "$tmpl" ]] && [[ "$(basename "$tmpl")" != "AGENTS.template.md" ]]; then
                cp "$tmpl" "$PROJECT_DIR/opencode-os/templates/"
            fi
        done
    fi
    
    # Install rules (for oh-my-opencode's rules injector)
    if [[ -d "$profile_dir/rules" ]]; then
        log_info "Installing conditional rules..."
        for rule in "$profile_dir/rules"/*.md; do
            if [[ -f "$rule" ]]; then
                cp "$rule" "$PROJECT_DIR/.claude/rules/"
            fi
        done
    fi
    
    # Create/update opencode.json with standards as instructions
    log_info "Configuring OpenCode..."
    local opencode_json="$PROJECT_DIR/.opencode/opencode.json"
    
    cat > "$opencode_json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "opencode-os/standards/global.md",
    "opencode-os/standards/backend.md",
    "opencode-os/standards/frontend.md",
    "opencode-os/standards/testing.md"
  ]
}
EOF
    
    log_info "Creating project configuration..."
    cat > "$PROJECT_DIR/opencode-os/config.yml" << EOF
# Amp-OS Configuration (OpenCode)
version: 1.0.0
profile: $PROFILE
project_name: "$PROJECT_NAME"
platform: opencode
installed: $(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

standards:
  global: true
  backend: true
  frontend: true
  testing: true

features:
  oh_my_opencode: $OMO_INSTALLED
EOF
    
    # Create AGENTS.md if it doesn't exist
    if [[ ! -f "$PROJECT_DIR/AGENTS.md" ]]; then
        log_info "Creating AGENTS.md..."
        if [[ -f "$profile_dir/templates/AGENTS.template.md" ]]; then
            sed "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" \
                "$profile_dir/templates/AGENTS.template.md" > "$PROJECT_DIR/AGENTS.md"
        fi
    else
        log_warning "AGENTS.md already exists, skipping (run /init to regenerate)"
    fi
    
    # Create initial roadmap
    if [[ ! -f "$PROJECT_DIR/opencode-os/product/roadmap.md" ]]; then
        log_info "Creating initial roadmap..."
        if [[ -f "$profile_dir/templates/roadmap.md" ]]; then
            sed "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" \
                "$profile_dir/templates/roadmap.md" > "$PROJECT_DIR/opencode-os/product/roadmap.md"
        fi
    fi
    
    log_success "Amp-OS installed successfully!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  Amp-OS is ready!"
    echo ""
    echo "  Next steps:"
    echo "    1. cd $PROJECT_DIR"
    echo "    2. opencode"
    echo "    3. Try: /plan-product to create your roadmap"
    echo ""
    echo "  Workflow commands:"
    echo "    /plan-product   /shape-spec   /write-spec"
    echo "    /create-tasks   /implement    /verify"
    echo ""
    
    if [[ "$OMO_INSTALLED" == "true" ]]; then
        echo "  Agents available: @oracle, @librarian, @explore"
    else
        echo -e "  ${YELLOW}Note: Install oh-my-opencode for @oracle, @librarian, @explore${NC}"
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Main entry point
main() {
    parse_args "$@"
    
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              Amp-OS Project Installer (OpenCode)              ║"
    echo "║       Spec-driven development for OpenCode                    ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_opencode || exit 1
    check_oh_my_opencode
    
    if ! validate_amp_os_install; then
        log_error "Amp-OS source not found. Please reinstall."
        exit 1
    fi
    
    install_opencode_os
}

main "$@"
