#!/usr/bin/env bash

# NixMod Installation Toolkit
# This script helps install and manage your NixOS configuration

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
echo -e "${BLUE}   NixMod Installation Toolkit   ${NC}"
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
    echo "  install             Install the configuration to the system"
    echo "  update              Update the system with the current configuration"
    echo "  test                Test the configuration without applying it"
    echo "  status              Show the current system status"
    echo "  backup              Create a backup of the current system configuration"
    echo "  flake-init          Initialize flake configuration"
    echo "  flake-update        Update flake inputs"
    echo "  help                Show this help message"
    echo ""
}

# Function to install configuration
install_config() {
    echo -e "${BLUE}Installing NixMod configuration...${NC}"
    
    # Check if hardware configuration exists
    if [ ! -f "/etc/nixos/hardware-configuration.nix" ]; then
        echo -e "${RED}Error: hardware-configuration.nix not found in /etc/nixos/${NC}"
        echo -e "${YELLOW}You may need to run 'nixos-generate-config' first.${NC}"
        exit 1
    fi
    
    # Backup the current configuration
    echo -e "${BLUE}Backing up current configuration...${NC}"
    if [ -d "/etc/nixos" ]; then
        BACKUP_DIR="/etc/nixos.backup.$(date +%Y%m%d%H%M%S)"
        cp -r /etc/nixos "$BACKUP_DIR"
        echo -e "${GREEN}Backup created at $BACKUP_DIR${NC}"
    fi
    
    # Copy configuration files
    echo -e "${BLUE}Copying configuration files...${NC}"
    mkdir -p /etc/nixos
    cp -r "$REPO_ROOT"/* /etc/nixos/
    cp "$REPO_ROOT/hardware-configuration.nix" /etc/nixos/
    
    # Apply the configuration
    echo -e "${BLUE}Applying configuration...${NC}"
    nixos-rebuild switch
    
    echo -e "${GREEN}NixMod configuration installed successfully!${NC}"
}

# Function to update the system
update_system() {
    echo -e "${BLUE}Updating NixMod...${NC}"
    
    if [ -f "$REPO_ROOT/flake.nix" ]; then
        echo -e "${BLUE}Updating using flakes...${NC}"
        cd "$REPO_ROOT" && nixos-rebuild switch --flake ".#nixos"
    else
        echo -e "${BLUE}Updating using traditional method...${NC}"
        nixos-rebuild switch
    fi
    
    echo -e "${GREEN}Update completed successfully!${NC}"
}

# Function to test the configuration
test_config() {
    echo -e "${BLUE}Testing NixMod configuration...${NC}"
    
    if [ -f "$REPO_ROOT/flake.nix" ]; then
        echo -e "${BLUE}Testing using flakes...${NC}"
        cd "$REPO_ROOT" && nixos-rebuild test --flake ".#nixos"
    else
        echo -e "${BLUE}Testing using traditional method...${NC}"
        nixos-rebuild test
    fi
    
    echo -e "${GREEN}Test completed. The configuration has not been permanently applied.${NC}"
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
    
    echo -e "\n${BLUE}Installed Packages:${NC}"
    nix-store -q --references /run/current-system/sw | wc -l
}

# Function to backup the current system configuration
backup_system() {
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    BACKUP_DIR="$HOME/nixmod_backup_$TIMESTAMP"
    
    echo -e "${BLUE}Creating backup of current system configuration...${NC}"
    mkdir -p "$BACKUP_DIR"
    
    # Backup NixOS configuration
    if [ -d "/etc/nixos" ]; then
        cp -r /etc/nixos "$BACKUP_DIR/"
    fi
    
    # Backup home configuration
    if [ -d "$HOME/.config" ]; then
        mkdir -p "$BACKUP_DIR/home_config"
        cp -r "$HOME/.config/hyprland" "$BACKUP_DIR/home_config/" 2>/dev/null || true
        cp -r "$HOME/.config/kitty" "$BACKUP_DIR/home_config/" 2>/dev/null || true
        cp -r "$HOME/.config/waybar" "$BACKUP_DIR/home_config/" 2>/dev/null || true
        cp -r "$HOME/.config/wofi" "$BACKUP_DIR/home_config/" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}Backup created at $BACKUP_DIR${NC}"
}

# Function to initialize flake configuration
init_flake() {
    if [ -f "$REPO_ROOT/flake.nix" ]; then
        echo -e "${YELLOW}flake.nix already exists. Overwrite? (y/N)${NC}"
        read -r response
        if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "Operation cancelled."
            exit 0
        fi
    fi
    
    echo -e "${BLUE}Creating flake.nix...${NC}"
    
    cat > "$REPO_ROOT/flake.nix" << 'EOF'
{
  description = "NixOS configuration with Hyprland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Optional useful inputs
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (import ./overlays/flameshot.nix)
        ];
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          
          specialArgs = { 
            inherit inputs;
          };
          
          modules = [
            # Core configuration
            ./configuration.nix
            
            # Import Hyprland flake's NixOS modules
            hyprland.nixosModules.default
            
            # Optional: Home Manager configuration
            # home-manager.nixosModules.home-manager
            # {
            #   home-manager.useGlobalPkgs = true;
            #   home-manager.useUserPackages = true;
            #   home-manager.users.nikmen = import ./home-manager/nikmen.nix;
            # }
          ];
        };
      };
    };
}
EOF

    echo -e "${BLUE}Creating .gitignore...${NC}"
    cat > "$REPO_ROOT/.gitignore" << 'EOF'
# Nix build artifacts
result
result-*

# Flake lock file (optional - you might want to commit this)
# flake.lock

# Direnv files (if you use direnv with nix)
.direnv

# Editor/IDE files
.vscode
.idea
*.swp
*~

# System files
.DS_Store
EOF

    echo -e "${GREEN}Flake configuration initialized successfully!${NC}"
    echo -e "${YELLOW}To use the flake configuration, run:${NC}"
    echo -e "  sudo nixos-rebuild switch --flake \"$REPO_ROOT#nixos\""
}

# Function to update flake inputs
update_flake() {
    if [ ! -f "$REPO_ROOT/flake.nix" ]; then
        echo -e "${RED}Error: flake.nix not found. Initialize flakes first with 'flake-init'.${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Updating flake inputs...${NC}"
    cd "$REPO_ROOT" && nix flake update
    
    echo -e "${GREEN}Flake inputs updated successfully!${NC}"
    echo -e "${YELLOW}To apply the updated inputs, run:${NC}"
    echo -e "  sudo nixos-rebuild switch --flake \"$REPO_ROOT#nixos\""
}

# Main script logic
case "$1" in
    install)
        install_config
        ;;
    update)
        update_system
        ;;
    test)
        test_config
        ;;
    status)
        check_status
        ;;
    backup)
        backup_system
        ;;
    flake-init)
        init_flake
        ;;
    flake-update)
        update_flake
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
