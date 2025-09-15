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
    echo "  install             Install the system configuration"
    echo "  update              Update the system with the current configuration"
    echo "  test                Test the configuration without applying it"
    echo "  status              Show the current system status"
    echo "  backup              Create a backup of the current system configuration"
    echo "  flake-init          Initialize flake configuration"
    echo "  flake-update        Update flake inputs"
    echo "  add-flake           Add a new flake module to the configuration"
    echo "  update-unixkit      Update UnixKit to latest commit and rebuild system"
    echo "  install-dotfiles    Install user dotfiles from separate repository"
    echo "  dotfiles-status     Check dotfiles repository and symlink status"
    echo "  sync-dotfiles       Sync changes from ~/.config back to dotfiles repository"
    echo "  help                Show this help message"
    echo ""
}

# Function to install system configuration
install_system() {
    echo -e "${BLUE}Installing NixMod system configuration...${NC}"
    
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
    
    # Copy system configuration files
    echo -e "${BLUE}Copying system configuration files...${NC}"
    mkdir -p /etc/nixos
    
    # Copy all system configuration files from nixmod-system
    cp -r "$REPO_ROOT/nixmod-system"/* /etc/nixos/
    
    # Ensure hardware configuration is copied
    cp "$REPO_ROOT/nixmod-system/hardware-configuration.nix" /etc/nixos/
    
    # Apply the configuration
    echo -e "${BLUE}Applying system configuration...${NC}"
    nixos-rebuild switch --flake /etc/nixos#nixos
    
    echo -e "${GREEN}NixMod system configuration installed successfully!${NC}"
    echo -e "${YELLOW}Note: User dotfiles are managed separately.${NC}"
    echo -e "${YELLOW}To install dotfiles, run: $0 install-dotfiles${NC}"
}

# Function to update the system
update_system() {
    echo -e "${BLUE}Updating NixMod system...${NC}"
    
    if [ -f "$REPO_ROOT/nixmod-system/flake.nix" ]; then
        echo -e "${BLUE}Updating using flakes...${NC}"
        cd "$REPO_ROOT/nixmod-system" && nixos-rebuild switch --flake ".#nixos"
    else
        echo -e "${BLUE}Updating using traditional method...${NC}"
        nixos-rebuild switch
    fi
    
    echo -e "${GREEN}System update completed successfully!${NC}"
}

# Function to test the configuration
test_config() {
    echo -e "${BLUE}Testing NixMod system configuration...${NC}"
    
    if [ -f "$REPO_ROOT/nixmod-system/flake.nix" ]; then
        echo -e "${BLUE}Testing using flakes...${NC}"
        cd "$REPO_ROOT/nixmod-system" && nixos-rebuild test --flake ".#nixos"
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
    
    echo -e "\n${BLUE}Dotfiles Status:${NC}"
    check_dotfiles_status
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
        cp -r "$HOME/.config" "$BACKUP_DIR/home_config/" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}Backup created at $BACKUP_DIR${NC}"
}

# Function to install dotfiles
install_dotfiles() {
    echo -e "${BLUE}Installing NixMod dotfiles...${NC}"
    
    # Check if dotfiles repository exists
    if [ ! -d "$HOME/.config/dotfiles" ]; then
        echo -e "${BLUE}Cloning dotfiles repository...${NC}"
        git clone https://github.com/yourusername/nixmod-dotfiles.git "$HOME/.config/dotfiles"
    fi
    
    # Install dotfiles
    cd "$HOME/.config/dotfiles"
    ./install.sh
    
    echo -e "${GREEN}Dotfiles installed successfully!${NC}"
}

# Function to check dotfiles status
check_dotfiles_status() {
    echo -e "${BLUE}Dotfiles Status:${NC}"
    echo -e "${BLUE}----------------${NC}"
    
    if [ -d "$HOME/.config/dotfiles" ]; then
        echo -e "${GREEN}✓ Dotfiles repository found at $HOME/.config/dotfiles${NC}"
        
        cd "$HOME/.config/dotfiles"
        
        # Check git status
        if git status --porcelain | grep -q .; then
            echo -e "${YELLOW}⚠ Uncommitted changes detected:${NC}"
            git status --short
        else
            echo -e "${GREEN}✓ No uncommitted changes${NC}"
        fi
        
        # Check if dotfiles are properly symlinked
        echo -e "\n${BLUE}Symlink Status:${NC}"
        for config_dir in hypr waybar kitty ghostty wofi wlogout superfile neofetch clipse cava; do
            if [ -L "$HOME/.config/$config_dir" ]; then
                if [ -e "$HOME/.config/$config_dir" ]; then
                    echo -e "${GREEN}✓ $config_dir properly linked${NC}"
                else
                    echo -e "${RED}✗ $config_dir broken symlink${NC}"
                fi
            elif [ -d "$HOME/.config/$config_dir" ]; then
                echo -e "${YELLOW}⚠ $config_dir is a directory (not symlinked)${NC}"
            else
                echo -e "${RED}✗ $config_dir not found${NC}"
            fi
        done
        
    else
        echo -e "${RED}✗ Dotfiles repository not found at $HOME/.config/dotfiles${NC}"
        echo -e "${YELLOW}Run 'install-dotfiles' to install.${NC}"
    fi
}

# Function to sync dotfiles back to repository
sync_dotfiles() {
    echo -e "${BLUE}Syncing dotfiles back to repository...${NC}"
    
    if [ ! -d "$HOME/.config/dotfiles" ]; then
        echo -e "${RED}Error: Dotfiles repository not found at $HOME/.config/dotfiles${NC}"
        echo -e "${YELLOW}Run 'install-dotfiles' first.${NC}"
        exit 1
    fi
    
    cd "$HOME/.config/dotfiles"
    ./sync.sh
    
    echo -e "${GREEN}Dotfiles synced successfully!${NC}"
    echo -e "${YELLOW}Don't forget to commit and push your changes.${NC}"
}

# Function to initialize flake configuration
init_flake() {
    if [ -f "$REPO_ROOT/nixmod-system/flake.nix" ]; then
        echo -e "${YELLOW}flake.nix already exists. Overwrite? (y/N)${NC}"
        read -r response
        if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "Operation cancelled."
            exit 0
        fi
    fi
    
    echo -e "${BLUE}Creating flake.nix...${NC}"
    
    cat > "$REPO_ROOT/nixmod-system/flake.nix" << 'EOF'
{
  description = "NixOS configuration with Hyprland and UnixKit";

  inputs = {
    # Base inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # UnixKit module inputs
    unixkit = {
      url = "github:nikitasmen/UnixKit";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, unixkit, ... }@inputs: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      lib = nixpkgs.lib;
      
      # Create UnixKit module directly
      unixkitModule = {
        module = { config, ... }: {
          imports = [ ./unixkit.nix ];
          _module.args.unixkit = unixkit;
        };
      };
      
    in {
      nixosConfigurations.nixos = lib.nixosSystem {
        inherit system;
        
        specialArgs = { 
          # Pass all inputs to modules
          inherit inputs;
        };
        
        modules = [
          # Main configuration file
          ./configuration.nix
          
          # Import modular flake components
          unixkitModule.module
        ];
      };
    };
}
EOF

    echo -e "${BLUE}Creating .gitignore...${NC}"
    cat > "$REPO_ROOT/nixmod-system/.gitignore" << 'EOF'
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
    echo -e "  sudo nixos-rebuild switch --flake \"$REPO_ROOT/nixmod-system#nixos\""
}

# Function to update flake inputs
update_flake() {
    if [ ! -f "$REPO_ROOT/nixmod-system/flake.nix" ]; then
        echo -e "${RED}Error: flake.nix not found. Initialize flakes first with 'flake-init'.${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Updating flake inputs...${NC}"
    cd "$REPO_ROOT/nixmod-system" && nix flake update
    
    echo -e "${GREEN}Flake inputs updated successfully!${NC}"
    echo -e "${YELLOW}To apply the updated inputs, run:${NC}"
    echo -e "  sudo nixos-rebuild switch --flake \"$REPO_ROOT/nixmod-system#nixos\""
}

# Function to add a flake module
add_flake() {
    echo -e "${BLUE}Adding new flake module...${NC}"
    
    # Pass all arguments to the add-flake.sh script
    "$SCRIPT_DIR/add-flake.sh" "$@"
    
    echo -e "${YELLOW}Don't forget to update your flake.nix to include the new module!${NC}"
}

# Function to update UnixKit to latest commit
update_unixkit() {
    echo -e "${BLUE}Updating UnixKit to latest commit...${NC}"
    
    # Execute the update-unixkit.sh script
    "$SCRIPT_DIR/update-unixkit.sh"
}

# Main script logic
case "$1" in
    install)
        install_system
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
    add-flake)
        shift  # Remove the 'add-flake' argument
        add_flake "$@"  # Pass remaining arguments
        ;;
    update-unixkit)
        update_unixkit
        ;;
    install-dotfiles)
        install_dotfiles
        ;;
    dotfiles-status)
        check_dotfiles_status
        ;;
    sync-dotfiles)
        sync_dotfiles
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