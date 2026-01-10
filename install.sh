#!/usr/bin/env bash

set -euo pipefail

# Colors for output
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly RESET='\033[0m'

# Functions for displaying messages
echo_info() {
    printf "%b[INFO]%b %s\\n" "${GREEN}" "${RESET}" "$1"
}

echo_warn() {
    printf "%b[WARN]%b %s\\n" "${YELLOW}" "${RESET}" "$1" >&2
}

echo_error() {
    printf "%b[ERROR]%b %s\\n" "${RED}" "${RESET}" "$1" >&2
}

echo_question() {
    printf "%b[QUESTION]%b %s\\n" "${BLUE}" "${RESET}" "$1"
}

ask_confirmation() {
    local prompt="$1 (Y/n): "
    local default="${2:-y}"
    local response
    read -r -p "$(echo_question "$prompt")" response
    response="${response:-$default}"
    case "${response,,}" in
        y|yes) return 0 ;;
        *) return 1 ;;
    esac
}

check_requirements() {
    local missing=()
    command -v git >/dev/null 2>&1 || missing+=("git")
    command -v nix-shell >/dev/null 2>&1 || missing+=("nix-shell")
    
    if (( ${#missing[@]} > 0 )); then
        echo_error "Missing required tools: ${missing[*]}"
        exit 1
    fi
}

get_config_values() {
    local default_username="${USER:-}"
    local default_hostname="${HOSTNAME:-}"
    
    # Getting a stateVersion
    local default_state_version="24.11"
    if [[ -f /etc/nixos/configuration.nix ]]; then
        local version_line
        version_line=$(grep 'system.stateVersion' /etc/nixos/configuration.nix)
        if [[ $version_line =~ \"([0-9]{2}\.[0-9]{2})\" ]]; then
            default_state_version="${BASH_REMATCH[1]}"
        fi
    fi
    
    # User data entry
    read -r -p "$(echo_question "Enter your username [${default_username}]: ")" username
    username="${username:-$default_username}"
    [[ -z "$username" ]] && { echo_error "Username cannot be empty"; exit 1; }

    read -r -p "$(echo_question "Enter hostname [${default_hostname}]: ")" hostname
    hostname="${hostname:-$default_hostname}"
    [[ -z "$hostname" ]] && { echo_error "Hostname cannot be empty"; exit 1; }

    read -r -p "$(echo_question "Enter stateVersion [${default_state_version}]: ")" state_version
    state_version="${state_version:-$default_state_version}"
    
    read -r -p "$(echo_question "Enter home-manager stateVersion [${default_state_version}]: ")" home_manager_state_version
    home_manager_state_version="${home_manager_state_version:-$state_version}"

    declare -g username hostname state_version home_manager_state_version
}

choose_template() {
    local templates=("nixos" "nixos-laptop")
    echo_question "Choose configuration template:"
    for i in "${!templates[@]}"; do
        printf "%d) %s\\n" "$((i+1))" "${templates[i]}"
    done

    local choice
    read -r -p "$(echo_question "Enter your choice [1]: ")" choice
    choice="${choice:-1}"

    if [[ ! "$choice" =~ ^[1-2]$ ]]; then
        echo_warn "Invalid choice, using default template"
        template="nixos"
    else
        template="${templates[choice-1]}"
    fi

    echo_info "Selected template: $template"
    declare -g template
}

setup_repository() {
    local repo_dir="${HOME}/.nix"
    
    if [[ ! -d "$repo_dir" ]]; then
        echo_info "Cloning repository..."
        git clone --quiet "https://github.com/TheIIIrd/nixos-workstation.git" "$repo_dir"
        cd "$repo_dir" || exit 1
        
        if ask_confirmation "Switch to unstable branch?"; then
            echo_info "Switching to unstable branch..."
            git checkout --quiet unstable
        fi
    else
        echo_info "Updating existing repository..."
        cd "$repo_dir" || exit 1
        git pull --quiet --ff-only
        
        if ask_confirmation "Would you like to switch branches?"; then
            echo_info "Available branches:"
            git --no-pager branch -a
            
            local branch_name
            read -r -p "$(echo_question "Enter branch name: ")" branch_name
            if git checkout --quiet "$branch_name" 2>/dev/null; then
                git pull --quiet --ff-only
            else
                echo_error "Branch $branch_name not found!"
                exit 1
            fi
        fi
    fi
}

backup_existing_host() {
    local hostname="$1"
    local repo_dir="${HOME}/.nix/hosts"
    local backup_dir backup_count=1
    
    while :; do
        backup_dir="${hostname}-backup-${backup_count}"
        [[ ! -d "${repo_dir}/${backup_dir}" ]] && break
        ((backup_count++))
    done

    mv -- "${repo_dir}/${hostname}" "${repo_dir}/${backup_dir}" || return 1
    echo "$backup_dir"
}

configure_host() {
    local hostname="$1" template="$2"
    local repo_dir="${HOME}/.nix"
    local hosts_dir="${repo_dir}/hosts"
    local backup_dir_name=""
    local valid_template="$template"
    
    cd "$hosts_dir" || { echo_error "Failed to enter hosts directory"; exit 1; }

    # Processing an existing configuration
    if [[ -d "$hostname" ]]; then
        echo_warn "Configuration for $hostname already exists!"
        if ask_confirmation "Backup existing configuration?"; then
            backup_dir_name=$(backup_existing_host "$hostname")
            echo_info "Backup created: ${backup_dir_name}"

            # If the host name matches the template, we use a backup copy as a valid template
            if [[ "$hostname" == "$template" ]]; then
                valid_template="$backup_dir_name"
                echo_info "Using backup as template: $valid_template"
            fi
        elif ask_confirmation "Overwrite existing configuration?"; then
            rm -rf -- "$hostname"
        else
            echo_error "Configuration aborted by user"
            exit 1
        fi
    fi

    # Checking the existence of a template
    if [[ ! -d "$valid_template" ]]; then
        # Search for a backup template
        for fallback in "nixos" "nixos-laptop"; do
            if [[ -d "$fallback" ]]; then
                valid_template="$fallback"
                echo_warn "Using fallback template: $valid_template"
                break
            fi
        done

        # Checking the success of the search
        if [[ ! -d "$valid_template" ]]; then
            echo_error "No valid templates found in: $hosts_dir"
            echo_error "Available directories:"
            find . -maxdepth 1 -type d -printf '%f\n' | tail -n +2
            exit 1
        fi
    fi

    # Copying the configuration
    echo_info "Creating configuration from template: $valid_template"
    cp -r -- "$valid_template" "$hostname"

    # Copying the hardware configuration
    cd "$hostname" || exit 1
    local hardware_src="/etc/nixos/hardware-configuration.nix"
    if [[ -f "$hardware_src" ]]; then
        cp --no-preserve=mode -- "$hardware_src" .
        echo_info "Hardware configuration copied"
    else
        echo_error "Missing hardware-configuration.nix at $hardware_src"
        exit 1
    fi
}

edit_flake() {
    local repo_dir="${HOME}/.nix"
    local flake_file="${repo_dir}/flake.nix"
    local tmp_file="${flake_file}.tmp"
    
    echo_info "Configuring flake.nix..."
    awk -v user="$username" \
        -v host="$hostname" \
        -v state="$state_version" \
        -v home_state="$home_manager_state_version" '
    {
        gsub(/theiiird/, user)
        if (/{ hostname = "nixos-blank"; stateVersion = "25.11"; }/) next
        gsub(/hostname = "nixos"/, "hostname = \"" host "\"")
        gsub(/stateVersion = "25.11"/, "stateVersion = \"" state "\"")
        gsub(/homeStateVersion = "25.11"/, "homeStateVersion = \"" home_state "\"")
        print
    }' "$flake_file" > "$tmp_file"
    
    mv -- "$tmp_file" "$flake_file"
}

edit_config_files() {
    local repo_dir="${HOME}/.nix"
    local files=(
        "hosts/${hostname}/local-packages.nix"
        "home-manager/home-packages.nix"
        "home-manager/modules/git.nix"
        "nixos/modules/boot/default.nix"
        "nixos/modules/desktop/default.nix"
        "nixos/modules/graphics/default.nix"
        "nixos/modules/core/default.nix"
    )
    
    echo_info "Opening configuration files for editing..."
    for file in "${files[@]}"; do
        local full_path="${repo_dir}/${file}"
        if [[ -f "$full_path" ]]; then
            nano "$full_path"
        else
            echo_warn "Skipping missing file: ${file}"
        fi
    done
}

handle_zapret() {
    if ask_confirmation "Run zapret blockcheck?"; then
        echo_info "Running zapret blockcheck..."
        nix-shell -p zapret --command blockcheck
    fi
    
    if ask_confirmation "Edit zapret configuration?"; then
        nano "${HOME}/.nix/nixos/modules/network/zapret.nix"
    fi
}

clean_repository() {
    local repo_dir="${HOME}/.nix"
    cd "$repo_dir" || return 1

    if ask_confirmation "Clean repository before rebuild?"; then
        if [[ -d ".git" ]] && ask_confirmation "Remove Git history?"; then
            echo_info "Removing Git metadata..."
            rm -rf .git .gitignore
        fi

        if [[ -d "screenshots" ]] && ask_confirmation "Remove screenshots?"; then
            echo_info "Removing screenshots folder..."
            rm -rf screenshots
        fi

        if [[ -f "flake.lock" ]] && ask_confirmation "Remove flake.lock?"; then
            echo_info "Removing flake.lock file..."
            rm flake.lock
        fi
    fi
}

rebuild_system() {
    local repo_dir="${HOME}/.nix"
    cd "$repo_dir" || exit 1

    if [[ -d ".git" ]]; then
        echo_info "Staging changes in git..."
        git add .
    fi

    echo_info "Rebuilding system..."
    sudo nixos-rebuild boot --flake ".#${hostname}"
}

main() {
    echo_info "Starting NixOS configuration setup"
    
    check_requirements
    get_config_values
    choose_template
    setup_repository
    configure_host "$hostname" "$template"
    edit_flake
    edit_config_files
    handle_zapret
    clean_repository

    if ask_confirmation "Rebuild system now?"; then
        rebuild_system
        echo_info "Configuration complete!"
        
        if ask_confirmation "Reboot now?"; then
            echo_info "Rebooting system..."
            sudo reboot
        else
            echo_info "Manual reboot required to apply changes"
        fi
    else
        echo_info "To rebuild later: cd ~/.nix && sudo nixos-rebuild boot --flake '.#${hostname}'"
    fi
}

main "$@"
