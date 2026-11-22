#!/usr/bin/env bash

# NixMod System Configuration Toolkit
# This script helps install and manage your NixOS system configuration

set -e # Exit on error

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
source "$SCRIPT_DIR/colors.sh"

# Print header
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}   NixMod System Toolkit        ${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}Note: Some operations may require root privileges.${NC}"
   echo ""
fi

# Check if NixOS is installed
if ! command -v nixos-version &> /dev/null; then
    echo -e "${RED}Error: NixOS not detected. This toolkit is designed for NixOS systems.${NC}"
    exit 1
fi

# Function to show help
show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install             Install/Apply the system configuration"
    echo "  update              Update the system with the current configuration"
    echo "  test                Test the configuration without applying it"
    echo "  status              Show the current system status"
    echo "  flake-update        Update flake inputs"
    echo "  update-unixkit      Update UnixKit to latest commit"
    echo "  health              Check system health (disk/mem/load)"
    echo "  clean               Remove generations older than 14 days and clean the Nix store"
    echo "  create-module NAME  Create a new module template"
    echo "  packages [list]     List packages from the modules' *.packages.json files"
    echo "  packages add NAME [LIST] [NOTE]"
    echo "                      Add a nixpkgs package to a list (default: applications)"
    echo "  packages remove NAME  Remove a package from whichever list has it"
    echo "  validate            Validate NixOS configuration (nix flake check)"
    echo "  help                Show this help message"
    echo ""
}

# Function to apply system configuration
apply_config() {
    local cmd="${1:-switch}"
    echo -e "${BLUE}Applying NixMod configuration ($cmd)...${NC}"
    
    # Check if we are in the repo root
    if [ ! -f "$REPO_ROOT/flake.nix" ]; then
        echo -e "${RED}Error: flake.nix not found in $REPO_ROOT/${NC}"
        exit 1
    fi
    
    # Fix for "repository path is not owned by current user" error when running as root
    # This happens because sudo runs as root, but the repo is owned by the regular user.
    if command -v git &> /dev/null; then
        echo -e "${BLUE}Ensuring Git repository is marked as safe...${NC}"
        # Mark the repo root as safe for both the current user and root
        git config --global --add safe.directory "$REPO_ROOT" 2>/dev/null || true
        sudo git config --global --add safe.directory "$REPO_ROOT" 2>/dev/null || true
    fi
    
    # Apply the configuration from the local repo root using 'path:' prefix to avoid Git ownership issues
    # Limit parallelism so the build doesn't peg every core / exhaust RAM.
    # Override per-machine with NIXMOD_JOBS / NIXMOD_CORES (0 = Nix default "all").
    # ponytail: static defaults, bump env vars if a beefier box wants more throughput
    local jobs="${NIXMOD_JOBS:-2}"
    local cores="${NIXMOD_CORES:-4}"
    sudo nixos-rebuild "$cmd" --flake "path:$REPO_ROOT#nixos" \
        --max-jobs "$jobs" --cores "$cores"
    
    echo -e "${GREEN}Operation completed successfully!${NC}"
    echo -e "${YELLOW}Note: Dotfiles are managed automatically via Home Manager.${NC}"
}

# Function to check system status
check_status() {
    echo -e "${BLUE}NixOS System Information:${NC}"
    echo -e "${BLUE}-----------------------${NC}"
    
    echo -e "${BLUE}NixOS Version:${NC}"
    nixos-version
    
    echo -e "\n${BLUE}Current System Generation:${NC}"
    nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -n 3
    
    echo -e "\n${BLUE}System Disk Usage:${NC}"
    df -h /nix | tail -n 1
}

# Function to update flake inputs
update_flake() {
    echo -e "${BLUE}Updating flake inputs...${NC}"
    # Use 'path:' to bypass git integration during update if it causes issues
    cd "$REPO_ROOT" && nix flake update --extra-experimental-features "nix-command flakes"
    echo -e "${GREEN}Flake inputs updated successfully!${NC}"
}

# Package lists: nixmod-system/modules/**/<list>.packages.json, the single source of truth shared with
# nixmod-gui. jq's default output format matches what the GUI writes, so the two never fight over layout.
packages_cmd() {
    local modules="$REPO_ROOT/nixmod-system/modules" name="$2" file
    local files
    files=$(find "$modules" -name '*.packages.json' | sort)
    case "${1:-list}" in
        list)
            for file in $files; do
                echo -e "${BLUE}$(basename "$file" .packages.json)${NC}  ${file#"$REPO_ROOT"/}"
                jq -r '.packages[] | "  \(.name)" + (if .note then "  # \(.note)" else "" end)' "$file"
            done
            ;;
        add)
            [ -n "$name" ] || { echo -e "${RED}Usage: $0 packages add NAME [LIST] [NOTE]${NC}"; exit 1; }
            local list="${3:-applications}" note="${4:-}" target owner
            target=$(echo "$files" | grep "/$list.packages.json$" || true)
            if [ -z "$target" ]; then
                echo -e "${RED}No package list named '$list'.${NC} Lists: $(for f in $files; do basename "$f" .packages.json; done | tr '\n' ' ')"
                exit 1
            fi
            owner=$(grep -l -F "\"name\": \"$name\"" $files | head -1 || true)
            if [ -n "$owner" ]; then
                echo -e "${YELLOW}$name is already in $(basename "$owner" .packages.json).${NC}"
                exit 0
            fi
            if ! nix --extra-experimental-features "nix-command flakes" eval --raw "nixpkgs#$name.name" >/dev/null 2>&1; then
                echo -e "${RED}'$name' isn't a package in nixpkgs.${NC} Search with: nix search nixpkgs $name"
                exit 1
            fi
            jq --arg n "$name" --arg note "$note" \
                '.packages += [{name: $n} + (if $note != "" then {note: $note} else {} end)]' "$target" > "$target.tmp"
            cat "$target.tmp" > "$target" && rm "$target.tmp"
            echo -e "${GREEN}Added $name to $list.${NC} Run 'sudo $0 update' to install it."
            ;;
        remove)
            [ -n "$name" ] || { echo -e "${RED}Usage: $0 packages remove NAME${NC}"; exit 1; }
            file=$(grep -l -F "\"name\": \"$name\"" $files | head -1 || true)
            if [ -z "$file" ]; then
                echo -e "${RED}$name isn't in any package list.${NC}"
                exit 1
            fi
            jq --arg n "$name" 'del(.packages[] | select(.name == $n))' "$file" > "$file.tmp"
            cat "$file.tmp" > "$file" && rm "$file.tmp"
            echo -e "${GREEN}Removed $name from $(basename "$file" .packages.json).${NC} Run 'sudo $0 update' to uninstall it."
            ;;
        *)
            echo -e "${RED}Unknown packages command: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Main script logic
case "$1" in
    install|update)
        apply_config "switch"
        ;;
    test)
        apply_config "test"
        ;;
    status)
        check_status
        ;;
    flake-update)
        update_flake
        ;;
    packages)
        packages_cmd "${@:2}"
        ;;
    update-unixkit)
        "$SCRIPT_DIR/update-unixkit.sh"
        ;;
    health|clean|create-module|validate)
        "$SCRIPT_DIR/helper.sh" "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        if [ -z "$1" ]; then
            show_help
        else
            echo -e "${RED}Unknown command: $1${NC}"
            show_help
            exit 1
        fi
        ;;
esac

exit 0
