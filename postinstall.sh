#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

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

execute_with_confirmation() {
    local description="$1"
    local command="$2"

    if ask_confirmation "$description"; then
        echo_info "Executing: $command"
        # Safe execution of a command through an array
        local cmd_array
        IFS=' ' read -r -a cmd_array <<< "$command"
        "${cmd_array[@]}"
        return $?
    fi
    return 0
}

run_nh_operations() {
    if command -v nh &> /dev/null; then
        execute_with_confirmation "Run nh home switch?" "nh home switch"
        execute_with_confirmation "Optimize nix store?" "nix store optimise"
    else
        echo_warn "nh command not found, skipping nh operations"
    fi
}

setup_flatpak() {
    if ! command -v flatpak &> /dev/null; then
        echo_warn "Flatpak is not installed, skipping configuration"
        return 1
    fi

    if ! ask_confirmation "Configure Flatpak? (This will add Flathub repository)"; then
        echo_info "Skipping Flatpak setup."
        return 0
    fi

    echo_info "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    # Installing gtk themes
    local themes=(
        "org.gtk.Gtk3theme.adw-gtk3"
        "org.gtk.Gtk3theme.adw-gtk3-dark"
    )

    if ask_confirmation "Install GTK themes for Flatpak apps?"; then
        for theme in "${themes[@]}"; do
            if flatpak install -y "$theme"; then
                echo_info "Installed theme: $theme"
            else
                echo_warn "Failed to install theme: $theme"
            fi
        done
    fi

    # Openh264 processing
    echo_warn "Note: openh264 installation might require accepting redistribution terms"
    if ask_confirmation "Mask openh264 to prevent potential conflicts?"; then
        if flatpak mask org.freedesktop.Platform.openh264 &> /dev/null; then
            echo_info "openh264 masked successfully"
        else
            echo_warn "Failed to mask openh264"
        fi

        if ask_confirmation "Install ffmpeg-full as an alternative video codec solution?"; then
            if flatpak install -y org.freedesktop.Platform.ffmpeg-full; then
                echo_info "ffmpeg-full installed successfully"
            else
                echo_warn "Failed to install ffmpeg-full"
            fi
        fi
    fi

    # Installing applications
    declare -A apps=(
        ["ch.tlaun.TL"]="TL - Minecraft Launcher"
        ["com.github.tchx84.Flatseal"]="Flatseal - Flatpak Permission Manager"
        ["com.heroicgameslauncher.hgl"]="HGL - Games Launcher for EGS, GOG and Amazon"
        ["page.codeberg.libre_menu_editor.LibreMenuEditor"]="Main Menu - Menu Editor"
    )

    for app_id in "${!apps[@]}"; do
        local app_name="${apps[$app_id]}"
        if ask_confirmation "Install $app_name?"; then
            if flatpak install -y flathub "$app_id"; then
                echo_info "Installed: $app_name"
                
                # Special treatment for TL
                if [[ "$app_id" == "ch.tlaun.TL" ]] && ask_confirmation "Set TL environment override?"; then
                    if flatpak --user override ch.tlaun.TL --env=TL_BOOTSTRAP_OPTIONS="-Dtl.useForce"; then
                        echo_info "Environment override set for TL"
                    else
                        echo_warn "Failed to set environment override for TL"
                    fi
                fi
            else
                echo_warn "Failed to install: $app_name"
            fi
        fi
    done
}

setup_gnome_keybindings() {
    if [[ "${XDG_CURRENT_DESKTOP:-}" =~ [Gg][Nn][Oo][Mm][Ee] ]]; then
        if command -v gsettings &> /dev/null && ask_confirmation "Set GNOME keyboard shortcut for input switching?"; then
            if gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Alt>Shift_L']"; then
                echo_info "GNOME keybinding set successfully"
            else
                echo_warn "Failed to set GNOME keybinding"
            fi
        fi
    fi
}

setup_fonts() {
    if ! ask_confirmation "Copy corefonts to ~/.local/share/fonts?"; then
        return 0
    fi

    local fonts_dir="${HOME}/.local/share/fonts"
    mkdir -p -- "$fonts_dir"

    # Search for corefonts in the nix store
    local corefonts_path
    corefonts_path=$(find /nix/store -maxdepth 1 -name "*-corefonts-1" -type d | head -n 1)

    if [[ -z "$corefonts_path" ]]; then
        echo_warn "Corefonts not found in nix store"
        return 1
    fi

    local font_src_dir="${corefonts_path}/share/fonts/truetype"
    if [[ ! -d "$font_src_dir" ]]; then
        echo_warn "Font source directory not found: ${font_src_dir}"
        return 1
    fi

    echo_info "Copying corefonts..."
    if cp -r --no-preserve=mode -- "$font_src_dir"/* "$fonts_dir"/; then
        echo_info "Fonts copied successfully"
        fc-cache -f -- "$fonts_dir"
    else
        echo_warn "Failed to copy fonts"
        return 1
    fi
}

setup_folder_structure() {
    local base_dir="${HOME}/BitLab"

    if ! ask_confirmation "Create recommended folder structure in ${base_dir}?"; then
        return 0
    fi

    # Defining the folder structure
    declare -A folders=(
        ["${base_dir}/CreationLab/ArtStore"]="Art projects"
        ["${base_dir}/CreationLab/CodeStore/ArcLab"]="Git projects"
        ["${base_dir}/CreationLab/CodeStore/CppLab"]="C++ projects"
        ["${base_dir}/CreationLab/CodeStore/CsLab"]="C# projects"
        ["${base_dir}/CreationLab/CodeStore/PyLab"]="Python projects"
        ["${base_dir}/CreationLab/CodeStore/RsLab"]="Rust projects"
        ["${base_dir}/CreationLab/DataStore"]="Data storage"
        ["${base_dir}/CreationLab/PcbStore"]="PCB designs"
        ["${base_dir}/GameLab/HeroicLab/Prefixes/default"]="Heroic Games Launcher prefixes"
        ["${base_dir}/VirtualLab/EngineLab"]="Virtualization disk images"
        ["${base_dir}/VirtualLab/SysImages"]="System images"
        ["${base_dir}/WorkBench"]="Workspace"
    )

    local created_count=0
    for folder in "${!folders[@]}"; do
        if [[ ! -d "$folder" ]]; then
            echo_info "Creating: ${folders[$folder]}"
            if mkdir -p -- "$folder"; then
                ((created_count++))
            else
                echo_warn "Failed to create: $folder"
            fi
        fi
    done

    echo_info "Created ${created_count} folders"
}

main() {
    echo_info "Starting post-reboot setup"

    run_nh_operations
    setup_flatpak
    setup_gnome_keybindings
    setup_fonts
    setup_folder_structure

    echo_info "Post-reboot setup completed!"

    if ask_confirmation "Reboot the system now?"; then
        echo_info "Rebooting system..."
        sudo reboot
    else
        echo_info "Manual reboot may be required to apply all changes"
    fi
}

main "$@"
