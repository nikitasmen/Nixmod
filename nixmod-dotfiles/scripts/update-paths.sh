#!/usr/bin/env bash

# Path Update Script for NixMod Dotfiles
# This script updates hardcoded paths in configuration files

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Default old path
OLD_USER_PATH="/home/nikmen"

# Function to update paths in a file
update_file_paths() {
  local file="$1"
  local old_path="$2"
  local new_path="$3"
  
  if [ -f "$file" ]; then
    # Create backup
    cp "$file" "$file.backup.$(date +%Y%m%d%H%M%S)"
    
    # Update paths
    sed -i "s|$old_path|$new_path|g" "$file"
    echo -e "${GREEN}Updated paths in $file${NC}"
  fi
}

# Function to update all configuration files
update_all_paths() {
  local new_path="$1"
  local old_path="$2"
  
  echo -e "${BLUE}Updating paths from $old_path to $new_path${NC}"
  
  # Find and update all configuration files
  find "$DOTFILES_DIR" -type f \( -name "*.conf" -o -name "*.json" -o -name "*.toml" -o -name "*.sh" \) -not -path "*/scripts/*" | while read -r file; do
    update_file_paths "$file" "$old_path" "$new_path"
  done
  
  echo -e "${GREEN}Path update completed${NC}"
}

# Function to update specific config
update_config_paths() {
  local config_name="$1"
  local new_path="$2"
  local old_path="$3"
  local config_dir="$DOTFILES_DIR/$config_name"
  
  if [ -d "$config_dir" ]; then
    echo -e "${BLUE}Updating paths in $config_name${NC}"
    
    find "$config_dir" -type f \( -name "*.conf" -o -name "*.json" -o -name "*.toml" -o -name "*.sh" \) | while read -r file; do
      update_file_paths "$file" "$old_path" "$new_path"
    done
    
    echo -e "${GREEN}Updated paths in $config_name${NC}"
  else
    echo -e "${RED}Config directory not found: $config_name${NC}"
    return 1
  fi
}

# Function to list configs that need path updates
list_configs() {
  echo -e "${BLUE}Configuration directories:${NC}"
  for dir in $(ls -1 "$DOTFILES_DIR" | grep -v -E '^(scripts|README\.md|install\.sh|sync\.sh|\.gitignore)$'); do
    if [ -d "$DOTFILES_DIR/$dir" ]; then
      echo "  - $dir"
    fi
  done
}

# Function to check for hardcoded paths
check_paths() {
  local old_path="$1"
  
  echo -e "${BLUE}Checking for hardcoded paths: $old_path${NC}"
  
  find "$DOTFILES_DIR" -type f \( -name "*.conf" -o -name "*.json" -o -name "*.toml" -o -name "*.sh" \) -not -path "*/scripts/*" | while read -r file; do
    if grep -q "$old_path" "$file"; then
      echo -e "${YELLOW}Found hardcoded path in $file${NC}"
      grep -n "$old_path" "$file" | head -3
    fi
  done
}

# Show usage
show_usage() {
  echo "Usage: $0 [OPTION] [CONFIG_NAME] [NEW_PATH]"
  echo ""
  echo "Options:"
  echo "  update [CONFIG_NAME] [NEW_PATH]  Update paths in all configs or specific one"
  echo "  list                              List available configurations"
  echo "  check [OLD_PATH]                  Check for hardcoded paths"
  echo "  help                              Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 update                         # Update all paths to current user home"
  echo "  $0 update hyprland /home/user     # Update paths in hyprland config"
  echo "  $0 check /home/nikmen             # Check for old hardcoded paths"
}

# Main script logic
case "$1" in
  update)
    if [ -z "$2" ]; then
      # Update all configs
      NEW_PATH="${2:-$HOME}"
      update_all_paths "$NEW_PATH" "$OLD_USER_PATH"
    else
      # Update specific config
      CONFIG_NAME="$2"
      NEW_PATH="${3:-$HOME}"
      update_config_paths "$CONFIG_NAME" "$NEW_PATH" "$OLD_USER_PATH"
    fi
    ;;
  list)
    list_configs
    ;;
  check)
    OLD_PATH="${2:-$OLD_USER_PATH}"
    check_paths "$OLD_PATH"
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
