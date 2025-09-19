#!/usr/bin/env bash

# Helper script for NixMod tasks

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

# Function to show system health
show_health() {
    echo -e "${BLUE}System Health Check${NC}"
    echo -e "${BLUE}-----------------${NC}"
    
    # Check disk space
    echo -e "\n${BLUE}Disk Space:${NC}"
    df -h / | tail -n 1
    
    # Check Nix store size
    echo -e "\n${BLUE}Nix Store Size:${NC}"
    du -sh /nix/store
    
    # Check memory usage
    echo -e "\n${BLUE}Memory Usage:${NC}"
    free -h
    
    # Check system load
    echo -e "\n${BLUE}System Load:${NC}"
    uptime
    
    # Check boot space
    echo -e "\n${BLUE}Boot Partition:${NC}"
    df -h /boot | tail -n 1
}

# Function to clean the system
clean_system() {
    echo -e "${BLUE}Cleaning NixOS System${NC}"
    echo -e "${BLUE}-------------------${NC}"
    
    # Garbage collection
    echo -e "\n${BLUE}Running garbage collection...${NC}"
    sudo nix-collect-garbage -d
    
    # Optimize store
    echo -e "\n${BLUE}Optimizing Nix store...${NC}"
    sudo nix-store --optimize
    
    # Clean old generations
    echo -e "\n${BLUE}Removing old generations...${NC}"
    sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
    sudo nixos-rebuild boot
    
    echo -e "\n${GREEN}System cleaned successfully!${NC}"
}


# Validation functions
validate_input() {
    local param="$1"
    local param_name="$2"
    if [[ -z "$param" ]]; then
        echo -e "${RED}Error: $param_name is required${NC}"
        exit 1
    fi
}

validate_directory() {
    local dir="$1"
    local dir_name="$2"
    if [[ ! -d "$dir" ]]; then
        echo -e "${RED}Error: $dir_name directory not found: $dir${NC}"
        exit 1
    fi
}

validate_file() {
    local file="$1"
    local file_name="$2"
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}Error: $file_name file not found: $file${NC}"
        exit 1
    fi
}

validate_positive_integer() {
    local num="$1"
    local param_name="$2"
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [[ "$num" -le 0 ]]; then
        echo -e "${RED}Error: $param_name must be a positive integer, got: $num${NC}"
        exit 1
    fi
}

validate_boolean() {
    local value="$1"
    local param_name="$2"
    if [[ "$value" != "true" && "$value" != "false" ]]; then
        echo -e "${RED}Error: $param_name must be 'true' or 'false', got: $value${NC}"
        exit 1
    fi
}

validate_url() {
    local url="$1"
    local param_name="$2"
    if [[ ! "$url" =~ ^https?:// ]] && [[ ! "$url" =~ ^github: ]] && [[ ! "$url" =~ ^git\+ ]]; then
        echo -e "${RED}Error: $param_name must be a valid URL or flake reference, got: $url${NC}"
        exit 1
    fi
}

validate_nixos_config() {
    echo -e "${BLUE}Validating NixOS configuration...${NC}"
    
    if [ -f "$REPO_ROOT/nixmod-system/flake.nix" ]; then
        cd "$REPO_ROOT/nixmod-system"
        if nix flake check 2>/dev/null; then
            echo -e "${GREEN}✓ Configuration is valid${NC}"
        else
            echo -e "${RED}✗ Configuration validation failed${NC}"
            echo -e "${YELLOW}Run 'nix flake check' for detailed error information${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}No flake.nix found, skipping validation${NC}"
    fi
}

# Function to create a new module
create_module() {
    validate_input "$1" "Module name"
    
    MODULE_NAME="$1"
    MODULE_DIR="$REPO_ROOT/modules"
    
    # Determine the appropriate subdirectory
    echo "Select module type:"
    echo "1. System module"
    echo "2. Desktop module"
    echo "3. Program module"
    echo "4. User module"
    read -r -p "Enter choice (1-4): " MODULE_TYPE
    
    case "$MODULE_TYPE" in
        1) SUBDIR="system" ;;
        2) SUBDIR="desktop" ;;
        3) SUBDIR="programs" ;;
        4) SUBDIR="users" ;;
        *) echo -e "${RED}Invalid choice.${NC}"; exit 1 ;;
    esac
    
    # Create module file
    MODULE_PATH="$MODULE_DIR/$SUBDIR/$MODULE_NAME.nix"
    if [ -f "$MODULE_PATH" ]; then
        echo -e "${RED}Error: Module already exists at $MODULE_PATH${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Creating module at $MODULE_PATH...${NC}"
    mkdir -p "$MODULE_DIR/$SUBDIR"
    
    cat > "$MODULE_PATH" << EOF
{ config, pkgs, lib, ... }:

{
  # Module: $MODULE_NAME
  # Description: Add a description here
  
  # Your configuration goes here
  
}
EOF
    
    # Update the default.nix file to include the new module
    DEFAULT_FILE="$MODULE_DIR/$SUBDIR/default.nix"
    if [ -f "$DEFAULT_FILE" ]; then
        # Check if the module is already included
        if grep -q "$MODULE_NAME.nix" "$DEFAULT_FILE"; then
            echo -e "${YELLOW}Module already included in $DEFAULT_FILE${NC}"
        else
            # Add the new module to the imports list
            sed -i.bak "s|{|{\n  imports = [\n    ./$MODULE_NAME.nix\n  ];|" "$DEFAULT_FILE"
            rm "$DEFAULT_FILE.bak"
            echo -e "${GREEN}Updated $DEFAULT_FILE to include the new module.${NC}"
        fi
    else
        # Create a new default.nix file
        cat > "$DEFAULT_FILE" << EOF
{ ... }:

{
  imports = [
    ./$MODULE_NAME.nix
  ];
}
EOF
        echo -e "${GREEN}Created new $DEFAULT_FILE file.${NC}"
    fi
    
    echo -e "\n${GREEN}Module created successfully at $MODULE_PATH${NC}"
    echo -e "${YELLOW}Edit the file to add your configuration.${NC}"
}

# Main script logic
case "$1" in
    health)
        show_health
        ;;
    clean)
        clean_system
        ;;
    create-module)
        create_module "$2"
        ;;
    validate)
        validate_nixos_config
        ;;
    *)
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  health              Check system health"
        echo "  clean               Clean the Nix store and remove old generations"
        echo "  create-module NAME  Create a new module template"
        echo "  validate            Validate NixOS configuration"
        exit 1
        ;;
esac

exit 0
