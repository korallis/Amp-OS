#!/bin/bash
# AMP-OS Project Installation Script
# Installs AMP-OS skills and templates into a project

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

# Default values
PROJECT_DIR=""
PROFILE="default"
USE_SYMLINKS="true"
PROJECT_NAME=""

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <project-directory>

Install AMP-OS into a project directory.

Options:
    -p, --profile PROFILE    Profile to use (default: default)
    -c, --copy               Copy files instead of symlinking
    -n, --name NAME          Project name (default: directory name)
    -h, --help               Show this help message

Examples:
    $(basename "$0") /path/to/my-project
    $(basename "$0") --profile rails --copy /path/to/rails-app
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

# Main installation function
install_amp_os() {
    local amp_os_home
    amp_os_home="$(get_amp_os_home)"
    
    log_info "Installing AMP-OS into: $PROJECT_DIR"
    log_info "Profile: $PROFILE"
    log_info "Project Name: $PROJECT_NAME"
    log_info "Use Symlinks: $USE_SYMLINKS"
    
    # Validate AMP-OS installation
    if ! validate_amp_os_install; then
        exit 1
    fi
    
    local profile_dir="$amp_os_home/profiles/$PROFILE"
    if [[ ! -d "$profile_dir" ]]; then
        log_error "Profile not found: $PROFILE"
        exit 1
    fi
    
    local config_file="$amp_os_home/config.yml"
    
    # Create project directories
    log_info "Creating project structure..."
    ensure_dir "$PROJECT_DIR/.claude/skills"
    ensure_dir "$PROJECT_DIR/amp-os/product"
    ensure_dir "$PROJECT_DIR/amp-os/specs"
    ensure_dir "$PROJECT_DIR/amp-os/templates"
    
    # Install skills
    log_info "Installing skills..."
    local skills
    skills="$(get_skills_to_install "$config_file" "$profile_dir")"
    
    for skill in $skills; do
        local source_skill="$profile_dir/skills/$skill"
        local dest_skill="$PROJECT_DIR/.claude/skills/amp-os-$skill"
        
        if [[ -d "$source_skill" ]]; then
            link_or_copy "$source_skill" "$dest_skill" "$USE_SYMLINKS"
        else
            log_warning "Skill not found: $skill"
        fi
    done
    
    # Copy templates (always copy, not symlink)
    log_info "Copying templates..."
    if [[ -d "$profile_dir/templates" ]]; then
        for template in "$profile_dir/templates"/*.md; do
            if [[ -f "$template" ]]; then
                local template_name
                template_name="$(basename "$template")"
                cp "$template" "$PROJECT_DIR/amp-os/templates/$template_name"
                log_info "Copied template: $template_name"
            fi
        done
    fi
    
    # Create project config
    log_info "Creating project configuration..."
    cat > "$PROJECT_DIR/amp-os/config.yml" << EOF
version: 1.0.0
profile: $PROFILE

# Project metadata
project_name: "$PROJECT_NAME"
tech_stack: []  # e.g., ["node", "react", "postgres"]

# Installation settings
use_symlinks: $USE_SYMLINKS

# Active standards (enable/disable per project)
standards:
  global: true
  backend: true
  frontend: true
  testing: true
EOF
    
    # Create AGENTS.md if it doesn't exist
    if [[ ! -f "$PROJECT_DIR/AGENTS.md" ]]; then
        log_info "Creating AGENTS.md..."
        if [[ -f "$profile_dir/templates/AGENTS.template.md" ]]; then
            sed "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" \
                "$profile_dir/templates/AGENTS.template.md" > "$PROJECT_DIR/AGENTS.md"
        else
            cat > "$PROJECT_DIR/AGENTS.md" << EOF
# $PROJECT_NAME

## AMP-OS Enabled

This project uses AMP-OS for spec-driven development.

### Standards (Always Apply)
Before writing code, load relevant standards:
- \`standards-global\` - Universal conventions (always)
- \`standards-frontend\` - React/Next.js patterns
- \`standards-backend\` - Database, API, payments
- \`standards-testing\` - Vitest, Playwright, MSW

### Workflow Skills
- \`plan-product\` - Create product roadmaps
- \`shape-spec\` - Research and gather requirements
- \`write-spec\` - Write specifications
- \`create-tasks\` - Break specs into tasks
- \`implement-tasks\` - Implement with standards
- \`verify-implementation\` - Final verification

### Commands
\`\`\`bash
# Add your project-specific commands here
# npm run build
# npm test
\`\`\`
EOF
        fi
    else
        log_warning "AGENTS.md already exists, skipping..."
    fi
    
    # Create initial roadmap
    if [[ ! -f "$PROJECT_DIR/amp-os/product/roadmap.md" ]]; then
        log_info "Creating initial roadmap..."
        cat > "$PROJECT_DIR/amp-os/product/roadmap.md" << EOF
# Product Roadmap: $PROJECT_NAME

> Created: $(date +%Y-%m-%d)

## Current Milestone

### Milestone 1: [Name]
- **Target:** [Date]
- **Status:** 🟡 In Progress

#### Features
- [ ] Feature 1
- [ ] Feature 2

---

## Backlog

### Future Milestones
- Milestone 2: [Description]
- Milestone 3: [Description]
EOF
    fi
    
    log_success "AMP-OS installed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Update amp-os/config.yml with your tech stack"
    echo "  2. Customize AGENTS.md with project-specific commands"
    echo "  3. Start with: Load amp-os-plan-product skill"
    echo ""
}

# Main entry point
main() {
    parse_args "$@"
    install_amp_os
}

main "$@"
