#!/usr/bin/env bash

# NixMod Dotfiles Installation Script
# This script installs user configuration files to ~/.config

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_TARGET="$HOME/.config"

# Print header
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}   NixMod Dotfiles Installer    ${NC}"
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
  
  # Get list of config directories (exclude scripts and README)
  config_dirs=$(ls -1 "$SCRIPT_DIR" | grep -v -E '^(scripts|README\.md|install\.sh|sync\.sh|\.gitignore)$')
  
  # Counter for successful installations
  local success_count=0
  local total_count=0
  
  # Process each config directory
  for dir in $config_dirs; do
    ((total_count++))
    source_path="$SCRIPT_DIR/$dir"
    target_path="$CONFIG_TARGET/$dir"
    
    symlink_config "$source_path" "$target_path" "$dir" && ((success_count++))
  done
  
  echo -e "${GREEN}Successfully installed $success_count of $total_count configurations${NC}"
}

# Function to install specific config
install_specific_config() {
  local config_name="$1"
  local source_path="$SCRIPT_DIR/$config_name"
  local target_path="$CONFIG_TARGET/$config_name"
  
  if [ -d "$source_path" ]; then
    symlink_config "$source_path" "$target_path" "$config_name"
    echo -e "${GREEN}Successfully installed $config_name configuration${NC}"
  else
    echo -e "${RED}Config not found: $config_name${NC}"
    echo -e "${YELLOW}Available configs: $(ls -1 "$SCRIPT_DIR" | grep -v -E '^(scripts|README\.md|install\.sh|sync\.sh|\.gitignore)$' | tr '\n' ' ')${NC}"
    return 1
  fi
}

# Function to list available configs
list_configs() {
  echo -e "${BLUE}Available configurations:${NC}"
  for dir in $(ls -1 "$SCRIPT_DIR" | grep -v -E '^(scripts|README\.md|install\.sh|sync\.sh|\.gitignore)$'); do
    echo "  - $dir"
  done
}

# Function to update hardcoded paths
update_paths() {
  local new_user_path="$1"
  local old_user_path="/home/nikmen"
  
  if [ -z "$new_user_path" ]; then
    new_user_path="$HOME"
  fi
  
  echo -e "${BLUE}Updating hardcoded paths from $old_user_path to $new_user_path${NC}"
  
  # Find and replace in all configuration files
  find "$SCRIPT_DIR" -type f \( -name "*.conf" -o -name "*.json" -o -name "*.toml" -o -name "*.sh" \) -exec sed -i "s|$old_user_path|$new_user_path|g" {} \;
  
  echo -e "${GREEN}Path update completed${NC}"
}

# Show usage
show_usage() {
  echo "Usage: $0 [OPTION] [CONFIG_NAME]"
  echo ""
  echo "Options:"
  echo "  install [CONFIG_NAME]  Install all configurations or specific one"
  echo "  list                   List available configurations"
  echo "  update-paths [PATH]    Update hardcoded paths (default: \$HOME)"
  echo "  help                   Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 install             # Install all configurations"
  echo "  $0 install hyprland    # Install only hyprland config"
  echo "  $0 update-paths        # Update paths to current user home"
  echo "  $0 update-paths /home/username  # Update paths to specific user"
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
  update-paths)
    update_paths "$2"
    ;;
  help|--help|-h)
    show_usage
    ;;
  *)
    if [ -z "$1" ]; then
      show_usage
    else
      echo -e "${RED}Unknown command: $1${NC}"
      show_usage
      exit 1
    fi
    ;;
esac

exit 0
