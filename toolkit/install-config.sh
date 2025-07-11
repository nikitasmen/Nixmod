#!/usr/bin/env bash

# Script to symlink configuration files from the Nixmod repo to the user's ~/.config directory

set -e

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_SOURCE="$REPO_ROOT/extConfig"
CONFIG_TARGET="$HOME/.config"

# Print header
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}   Nixmod Config Installation   ${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Function to create a backup of an existing config directory
backup_config() {
  local dir="$1"
  if [ -e "$dir" ] || [ -L "$dir" ]; then
    local backup_dir="${dir}.backup.$(date +%Y%m%d%H%M%S)"
    echo -e "${YELLOW}Backing up existing config: $dir -> $backup_dir${NC}"
    mv "$dir" "$backup_dir"
  fi
}

# Function to symlink a config directory
symlink_config() {
  local source_dir="$1"
  local target_dir="$2"
  local dir_name="$3"
  
  # Only proceed if source directory exists
  if [ ! -d "$source_dir" ]; then
    echo -e "${RED}Source directory not found: $source_dir${NC}"
    return 1
  fi

  # Create target parent directory if it doesn't exist
  mkdir -p "$(dirname "$target_dir")"
  
  # Backup existing config
  backup_config "$target_dir"
  
  # Create symlink
  echo -e "${BLUE}Linking $dir_name config: $source_dir -> $target_dir${NC}"
  ln -sf "$source_dir" "$target_dir"
}

# Function to install all configs
install_all_configs() {
  echo -e "${BLUE}Installing all configurations to $CONFIG_TARGET${NC}"
  
  # Ensure the ~/.config directory exists
  mkdir -p "$CONFIG_TARGET"
  
  # Get list of config directories
  config_dirs=$(ls -1 "$CONFIG_SOURCE")
  
  # Counter for successful installations
  local success_count=0
  local total_count=0
  
  # Process each config directory
  for dir in $config_dirs; do
    ((total_count++))
    source_path="$CONFIG_SOURCE/$dir"
    target_path="$CONFIG_TARGET/$dir"
    
    # Special case for superfile which has a nested directory structure
    if [ "$dir" = "superfile" ]; then
      source_path="$CONFIG_SOURCE/$dir/superfile"
    fi
    
    symlink_config "$source_path" "$target_path" "$dir" && ((success_count++))
  done
  
  echo -e "${GREEN}Successfully installed $success_count of $total_count configurations${NC}"
}

# Function to install specific config
install_specific_config() {
  local config_name="$1"
  local source_path="$CONFIG_SOURCE/$config_name"
  local target_path="$CONFIG_TARGET/$config_name"
  
  # Special case for superfile which has a nested directory structure
  if [ "$config_name" = "superfile" ]; then
    source_path="$CONFIG_SOURCE/$config_name/superfile"
  fi
  
  if [ -d "$source_path" ]; then
    symlink_config "$source_path" "$target_path" "$config_name"
    echo -e "${GREEN}Successfully installed $config_name configuration${NC}"
  else
    echo -e "${RED}Config not found: $config_name${NC}"
    echo -e "${YELLOW}Available configs: $(ls -1 "$CONFIG_SOURCE" | tr '\n' ' ')${NC}"
    return 1
  fi
}

# Function to list available configs
list_configs() {
  echo -e "${BLUE}Available configurations:${NC}"
  for dir in $(ls -1 "$CONFIG_SOURCE"); do
    echo "  - $dir"
  done
}

# Show usage
show_usage() {
  echo "Usage: $0 [OPTION]"
  echo ""
  echo "Options:"
  echo "  install                Install all configurations"
  echo "  install CONFIG_NAME    Install a specific configuration"
  echo "  list                   List available configurations"
  echo "  help                   Show this help message"
  echo ""
  echo "Example:"
  echo "  $0 install             # Install all configurations"
  echo "  $0 install hyprland    # Install only hyprland config"
}

# Main script logic
case "$1" in
  install)
    if [ -z "$2" ]; then
      install_all_configs
    else
      install_specific_config "$2"
    fi
    ;;
  list)
    list_configs
    ;;
  help|--help|-h)
    show_usage
    ;;
  *)
    show_usage
    exit 1
    ;;
esac

exit 0
