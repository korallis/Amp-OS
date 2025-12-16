#!/bin/bash
# AMP-OS Project Update Script
# Updates AMP-OS skills in an existing project installation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

# Default values
PROJECT_DIR=""
FORCE="false"

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <project-directory>

Update AMP-OS skills in an existing project installation.

Options:
    -f, --force     Force update even if using symlinks
    -h, --help      Show this help message

Examples:
    $(basename "$0") /path/to/my-project
    $(basename "$0") --force .

EOF
    exit 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--force)
                FORCE="true"
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
    
    PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || {
        log_error "Project directory does not exist: $PROJECT_DIR"
        exit 1
    }
}

# Check if project has AMP-OS installed
check_amp_os_project() {
    if [[ ! -f "$PROJECT_DIR/amp-os/config.yml" ]]; then
        log_error "AMP-OS not installed in this project"
        log_info "Run amp-project-install.sh first"
        exit 1
    fi
}

# Main update function
update_amp_os() {
    local amp_os_home
    amp_os_home="$(get_amp_os_home)"
    
    log_info "Updating AMP-OS in: $PROJECT_DIR"
    
    # Validate installations
    if ! validate_amp_os_install; then
        exit 1
    fi
    check_amp_os_project
    
    # Read project config
    local project_config="$PROJECT_DIR/amp-os/config.yml"
    local profile
    profile="$(read_yaml_value "$project_config" "profile")"
    profile="${profile:-default}"
    
    local use_symlinks
    use_symlinks="$(read_yaml_value "$project_config" "use_symlinks")"
    use_symlinks="${use_symlinks:-true}"
    
    local profile_dir="$amp_os_home/profiles/$profile"
    local config_file="$amp_os_home/config.yml"
    
    log_info "Profile: $profile"
    log_info "Use Symlinks: $use_symlinks"
    
    # Check if using symlinks (no update needed unless forced)
    if [[ "$use_symlinks" == "true" ]] && [[ "$FORCE" != "true" ]]; then
        log_info "Project uses symlinks - skills are automatically up to date"
        log_info "Use --force to re-create symlinks if needed"
        exit 0
    fi
    
    # Update skills
    log_info "Updating skills..."
    local skills
    skills="$(get_skills_to_install "$config_file" "$profile_dir")"
    
    local updated=0
    local skipped=0
    
    for skill in $skills; do
        local source_skill="$profile_dir/skills/$skill"
        local dest_skill="$PROJECT_DIR/.claude/skills/amp-os-$skill"
        
        if [[ -d "$source_skill" ]]; then
            link_or_copy "$source_skill" "$dest_skill" "$use_symlinks"
            ((updated++))
        else
            log_warning "Skill not found in profile: $skill"
            ((skipped++))
        fi
    done
    
    log_success "Update complete!"
    log_info "Updated: $updated skills"
    if [[ $skipped -gt 0 ]]; then
        log_warning "Skipped: $skipped skills (not found in profile)"
    fi
}

# Main entry point
main() {
    parse_args "$@"
    update_amp_os
}

main "$@"
