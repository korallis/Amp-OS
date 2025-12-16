#!/bin/bash
# AMP-OS Create Profile Script
# Creates a new profile by copying from default or another profile

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

# Default values
PROFILE_NAME=""
BASE_PROFILE="default"

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <profile-name>

Create a new AMP-OS profile.

Options:
    -b, --base PROFILE    Base profile to copy from (default: default)
    -h, --help            Show this help message

Examples:
    $(basename "$0") rails
    $(basename "$0") --base default python
    $(basename "$0") -b rails django

EOF
    exit 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -b|--base)
                BASE_PROFILE="$2"
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
                PROFILE_NAME="$1"
                shift
                ;;
        esac
    done
    
    if [[ -z "$PROFILE_NAME" ]]; then
        log_error "Profile name is required"
        usage
    fi
    
    # Validate profile name (lowercase, hyphens only)
    if [[ ! "$PROFILE_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
        log_error "Profile name must be lowercase, start with a letter, and contain only letters, numbers, and hyphens"
        exit 1
    fi
}

# Main create function
create_profile() {
    local amp_os_home
    amp_os_home="$(get_amp_os_home)"
    
    log_info "Creating profile: $PROFILE_NAME"
    log_info "Base profile: $BASE_PROFILE"
    
    # Validate AMP-OS installation
    if ! validate_amp_os_install; then
        exit 1
    fi
    
    local base_dir="$amp_os_home/profiles/$BASE_PROFILE"
    local new_dir="$amp_os_home/profiles/$PROFILE_NAME"
    
    # Check base profile exists
    if [[ ! -d "$base_dir" ]]; then
        log_error "Base profile not found: $BASE_PROFILE"
        exit 1
    fi
    
    # Check new profile doesn't exist
    if [[ -d "$new_dir" ]]; then
        log_error "Profile already exists: $PROFILE_NAME"
        log_info "Delete $new_dir first if you want to recreate it"
        exit 1
    fi
    
    # Copy profile
    log_info "Copying from $BASE_PROFILE..."
    cp -r "$base_dir" "$new_dir"
    
    log_success "Profile created: $PROFILE_NAME"
    echo ""
    echo "Profile location: $new_dir"
    echo ""
    echo "Next steps:"
    echo "  1. Customize skills in: $new_dir/skills/"
    echo "  2. Update templates in: $new_dir/templates/"
    echo "  3. Use with: amp-project-install.sh --profile $PROFILE_NAME /path/to/project"
    echo ""
}

# Main entry point
main() {
    parse_args "$@"
    create_profile
}

main "$@"
