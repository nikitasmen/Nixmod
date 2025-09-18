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
    echo "  install-dotfiles    Install user dotfiles by creating individual symlinks for all discovered apps"
    echo "  dotfiles-status     Check individual application symlink status for all discovered apps"
    echo "  sync-dotfiles       Sync changes from source dotfiles directory"
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
    
    # Check if local dotfiles directory exists
    if [ ! -d "$REPO_ROOT/nixmod-dotfiles" ]; then
        echo -e "${RED}Error: nixmod-dotfiles directory not found at $REPO_ROOT/nixmod-dotfiles${NC}"
        echo -e "${YELLOW}Make sure you're running this from the NixMod repository root.${NC}"
        exit 1
    fi
    
    # Ensure .config directory exists
    mkdir -p "$HOME/.config"
    
    echo -e "${BLUE}Discovering and creating symlinks for all configurations...${NC}"
    
    # Find all directories in nixmod-dotfiles (excluding hidden files and special directories)
    local config_apps=()
    while IFS= read -r -d '' dir; do
        # Get just the directory name (not full path)
        local dirname=$(basename "$dir")
        # Skip special directories and hidden files
        if [[ "$dirname" != "scripts" && "$dirname" != ".git" && ! "$dirname" =~ ^\..*$ ]]; then
            config_apps+=("$dirname")
        fi
    done < <(find "$REPO_ROOT/nixmod-dotfiles" -maxdepth 1 -type d -print0)
    
    echo -e "${BLUE}Found ${#config_apps[@]} configuration directories: ${config_apps[*]}${NC}"
    
    # Check if any directories were found
    if [ ${#config_apps[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠ No configuration directories found in nixmod-dotfiles${NC}"
        echo -e "${YELLOW}Make sure the nixmod-dotfiles directory contains configuration folders.${NC}"
        return 1
    fi
    
    # Create individual symlinks for each discovered application
    for app in "${config_apps[@]}"; do
        local source_path="$REPO_ROOT/nixmod-dotfiles/$app"
        local target_path="$HOME/.config/$app"
        
        if [ -d "$source_path" ]; then
            # Remove existing directory or symlink if it exists
            if [ -e "$target_path" ] || [ -L "$target_path" ]; then
                echo -e "${YELLOW}Removing existing $app configuration...${NC}"
                rm -rf "$target_path"
            fi
            
            # Create symlink
            echo -e "${BLUE}Linking $app configuration...${NC}"
            ln -sf "$source_path" "$target_path"
            
            if [ -L "$target_path" ] && [ -e "$target_path" ]; then
                echo -e "${GREEN}✓ $app linked successfully${NC}"
            else
                echo -e "${RED}✗ Failed to link $app${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ $app directory not found in nixmod-dotfiles${NC}"
        fi
    done
    
    echo -e "${GREEN}Dotfiles installed successfully!${NC}"
    echo -e "${BLUE}Individual application configurations have been symlinked to ~/.config/${NC}"
}

# Function to check dotfiles status
check_dotfiles_status() {
    echo -e "${BLUE}Dotfiles Status:${NC}"
    echo -e "${BLUE}----------------${NC}"
    
    # Find all directories in nixmod-dotfiles (excluding hidden files and special directories)
    local config_apps=()
    while IFS= read -r -d '' dir; do
        # Get just the directory name (not full path)
        local dirname=$(basename "$dir")
        # Skip special directories and hidden files
        if [[ "$dirname" != "scripts" && "$dirname" != ".git" && ! "$dirname" =~ ^\..*$ ]]; then
            config_apps+=("$dirname")
        fi
    done < <(find "$REPO_ROOT/nixmod-dotfiles" -maxdepth 1 -type d -print0)
    
    # Check if any directories were found
    if [ ${#config_apps[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠ No configuration directories found in nixmod-dotfiles${NC}"
        echo -e "${YELLOW}Make sure the nixmod-dotfiles directory contains configuration folders.${NC}"
        return 1
    fi
    
    # Check if nixmod-dotfiles source directory exists
    if [ -d "$REPO_ROOT/nixmod-dotfiles" ]; then
        echo -e "${GREEN}✓ Source dotfiles directory found at $REPO_ROOT/nixmod-dotfiles${NC}"
        
        # Check git status if it's a git repository
        cd "$REPO_ROOT/nixmod-dotfiles"
        if [ -d ".git" ]; then
            if git status --porcelain | grep -q .; then
                echo -e "${YELLOW}⚠ Uncommitted changes in source directory:${NC}"
                git status --short
            else
                echo -e "${GREEN}✓ No uncommitted changes in source directory${NC}"
            fi
        else
            echo -e "${BLUE}ℹ Source directory is not a git repository${NC}"
        fi
    else
        echo -e "${RED}✗ Source dotfiles directory not found at $REPO_ROOT/nixmod-dotfiles${NC}"
        echo -e "${YELLOW}Make sure you're running this from the NixMod repository root.${NC}"
        return 1
    fi
    
    # Check individual application symlinks
    echo -e "\n${BLUE}Application Symlink Status:${NC}"
    local linked_count=0
    local total_count=${#config_apps[@]}
    
    for app in "${config_apps[@]}"; do
        local target_path="$HOME/.config/$app"
        local source_path="$REPO_ROOT/nixmod-dotfiles/$app"
        
        if [ -L "$target_path" ]; then
            if [ -e "$target_path" ]; then
                local target=$(readlink "$target_path")
                if [ "$target" = "$source_path" ]; then
                    echo -e "${GREEN}✓ $app properly linked to source${NC}"
                    ((linked_count++))
                else
                    echo -e "${YELLOW}⚠ $app linked to different location: $target${NC}"
                fi
            else
                echo -e "${RED}✗ $app broken symlink${NC}"
            fi
        elif [ -d "$target_path" ]; then
            echo -e "${YELLOW}⚠ $app is a directory (not symlinked)${NC}"
        else
            echo -e "${RED}✗ $app not found${NC}"
        fi
    done
    
    echo -e "\n${BLUE}Summary:${NC}"
    echo -e "${BLUE}Linked: $linked_count/$total_count applications${NC}"
    
    if [ $linked_count -eq $total_count ]; then
        echo -e "${GREEN}✓ All dotfiles are properly linked!${NC}"
    elif [ $linked_count -gt 0 ]; then
        echo -e "${YELLOW}⚠ Some dotfiles are not linked. Run 'install-dotfiles' to fix.${NC}"
    else
        echo -e "${RED}✗ No dotfiles are linked. Run 'install-dotfiles' to install.${NC}"
    fi
}

# Function to sync dotfiles back to repository
sync_dotfiles() {
    echo -e "${BLUE}Syncing dotfiles back to repository...${NC}"
    
    # Check if source dotfiles directory exists
    if [ ! -d "$REPO_ROOT/nixmod-dotfiles" ]; then
        echo -e "${RED}Error: Source dotfiles directory not found at $REPO_ROOT/nixmod-dotfiles${NC}"
        echo -e "${YELLOW}Make sure you're running this from the NixMod repository root.${NC}"
        exit 1
    fi
    
    cd "$REPO_ROOT/nixmod-dotfiles"
    
    # Check if sync.sh exists and is executable
    if [ -f "./sync.sh" ] && [ -x "./sync.sh" ]; then
        echo -e "${BLUE}Running sync script...${NC}"
        ./sync.sh
        echo -e "${GREEN}Dotfiles synced successfully!${NC}"
    else
        echo -e "${YELLOW}sync.sh not found or not executable, skipping sync${NC}"
    fi
    
    # Check if it's a git repository and suggest committing
    if [ -d ".git" ]; then
        echo -e "${YELLOW}Don't forget to commit and push your changes.${NC}"
        echo -e "${BLUE}To commit changes:${NC}"
        echo -e "  cd $REPO_ROOT/nixmod-dotfiles"
        echo -e "  git add ."
        echo -e "  git commit -m 'Update dotfiles'"
        echo -e "  git push"
    fi
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