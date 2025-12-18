#!/bin/bash
# Unified Installer for AMP-OS / OpenCode-OS
# Supports both Amp CLI and OpenCode platforms

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO="korallis/Amp-OS"
INSTALL_DIR="${AMP_OS_HOME:-$HOME/Amp-OS}"
BRANCH="${AMP_OS_BRANCH:-main}"
PLATFORM=""

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

check_requirements() {
    if ! command -v git &> /dev/null; then
        log_error "git is required but not installed"
        exit 1
    fi
}

show_banner() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}      ${GREEN}Spec-Driven Development Framework${NC}                       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}      Spec-driven development for AI assistants                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}      Supports: ${BLUE}Amp CLI${NC} | ${BLUE}OpenCode${NC}                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

select_platform() {
    echo "Which platform are you using?"
    echo ""
    echo -e "  ${BLUE}1)${NC} Amp CLI (Sourcegraph) - ampcode.com"
    echo -e "  ${BLUE}2)${NC} OpenCode (SST) - opencode.ai"
    echo ""
    
    while true; do
        read -p "Select platform [1/2]: " -n 1 -r choice
        echo
        case $choice in
            1)
                PLATFORM="amp"
                log_info "Selected: Amp CLI"
                break
                ;;
            2)
                PLATFORM="opencode"
                log_info "Selected: OpenCode"
                break
                ;;
            *)
                echo "Please enter 1 or 2"
                ;;
        esac
    done
}

install_repository() {
    log_info "Installing to: $INSTALL_DIR"
    
    if [[ -d "$INSTALL_DIR" ]]; then
        log_info "Installation already exists at $INSTALL_DIR"
        read -p "Update existing installation? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Updating..."
            cd "$INSTALL_DIR"
            git pull origin "$BRANCH"
            chmod +x "$INSTALL_DIR/scripts/"*.sh
            log_success "Updated successfully!"
        else
            log_info "Keeping existing installation"
        fi
    else
        log_info "Cloning repository..."
        git clone --depth 1 --branch "$BRANCH" "https://github.com/$REPO.git" "$INSTALL_DIR"
        chmod +x "$INSTALL_DIR/scripts/"*.sh
        log_success "Installation complete!"
    fi
}

show_amp_instructions() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "  ${GREEN}AMP-OS installed successfully!${NC}"
    echo ""
    echo "  To add to a project:"
    echo -e "    ${CYAN}$INSTALL_DIR/scripts/amp-project-install.sh /path/to/project${NC}"
    echo ""
    echo "  Or add scripts to PATH:"
    echo -e "    ${CYAN}export PATH=\"\$PATH:$INSTALL_DIR/scripts\"${NC}"
    echo ""
    echo "  Then use skills in Amp:"
    echo "    • Load amp-os-plan-product to create a roadmap"
    echo "    • Load amp-os-write-spec to write specifications"
    echo "    • Load amp-os-implement-tasks to implement"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

show_opencode_instructions() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "  ${GREEN}OpenCode-OS installed successfully!${NC}"
    echo ""
    echo -e "  ${YELLOW}IMPORTANT: oh-my-opencode plugin is REQUIRED${NC}"
    echo ""
    echo "  If not installed, add to ~/.config/opencode/opencode.json:"
    echo -e "    ${CYAN}{ \"plugin\": [\"oh-my-opencode\"] }${NC}"
    echo ""
    echo "  Then add to a project:"
    echo -e "    ${CYAN}$INSTALL_DIR/scripts/opencode-project-install.sh /path/to/project${NC}"
    echo ""
    echo "  Or add scripts to PATH:"
    echo -e "    ${CYAN}export PATH=\"\$PATH:$INSTALL_DIR/scripts\"${NC}"
    echo ""
    echo "  Workflow commands available after installation:"
    echo "    • /plan-product   - Strategic planning"
    echo "    • /shape-spec     - Research requirements"
    echo "    • /write-spec     - Write specifications"
    echo "    • /create-tasks   - Break into tasks"
    echo "    • /implement      - TDD implementation"
    echo "    • /verify         - Verification"
    echo ""
    echo "  oh-my-opencode docs:"
    echo "    https://github.com/code-yeongyu/oh-my-opencode"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

main() {
    show_banner
    check_requirements
    select_platform
    install_repository
    
    case $PLATFORM in
        amp)
            show_amp_instructions
            ;;
        opencode)
            show_opencode_instructions
            ;;
    esac
}

main
