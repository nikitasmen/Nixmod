#!/usr/bin/env bash

# NixMod System Configuration Toolkit
# This script helps install and manage your NixOS system configuration

set -e # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

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
    echo "  help                Show this help message"
    echo ""
}

# Function to apply system configuration
apply_config() {
    local cmd="${1:-switch}"
    echo -e "${BLUE}Applying NixMod configuration ($cmd)...${NC}"
    
    # Check if we are in the repo root
    if [ ! -f "$REPO_ROOT/nixmod-system/flake.nix" ]; then
        echo -e "${RED}Error: flake.nix not found in $REPO_ROOT/nixmod-system/${NC}"
        exit 1
    fi
    
    # Apply the configuration from the local repo
    sudo nixos-rebuild "$cmd" --flake "$REPO_ROOT/nixmod-system#nixos"
    
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
    cd "$REPO_ROOT/nixmod-system" && nix flake update
    echo -e "${GREEN}Flake inputs updated successfully!${NC}"
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
    update-unixkit)
        ./toolkit/update-unixkit.sh
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
