#!/usr/bin/env bash

# NixMod Dotfiles Synchronization Script
# This script syncs changes from ~/.config back to the dotfiles repository

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE="$HOME/.config"

# Print header
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}   NixMod Dotfiles Sync         ${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Function to sync a config directory
sync_config() {
  local config_name="$1"
  local source_path="$CONFIG_SOURCE/$config_name"
  local target_path="$SCRIPT_DIR/$config_name"
  
  if [ ! -d "$source_path" ]; then
    echo -e "${RED}Source directory not found: $source_path${NC}"
    return 1
  fi

  # Create target directory if it doesn't exist
  mkdir -p "$target_path"
  
  # Sync the directory
  echo -e "${BLUE}Syncing $config_name: $source_path -> $target_path${NC}"
  rsync -av --delete "$source_path/" "$target_path/"
  
  echo -e "${GREEN}Successfully synced $config_name${NC}"
}

# Function to sync all configs
sync_all_configs() {
  echo -e "${BLUE}Syncing all configurations from $CONFIG_SOURCE${NC}"
  
  # Get list of config directories that exist in both source and target
  config_dirs=$(ls -1 "$SCRIPT_DIR" | grep -v -E '^(scripts|README\.md|install\.sh|sync\.sh|\.gitignore)$')
  
  # Counter for successful syncs
  local success_count=0
  local total_count=0
  
  # Process each config directory
  for dir in $config_dirs; do
    if [ -d "$CONFIG_SOURCE/$dir" ]; then
      ((total_count++))
      sync_config "$dir" && ((success_count++))
    else
      echo -e "${YELLOW}Config directory not found in ~/.config: $dir${NC}"
    fi
  done
  
  echo -e "${GREEN}Successfully synced $success_count of $total_count configurations${NC}"
}

# Function to sync specific config
sync_specific_config() {
  local config_name="$1"
  local source_path="$CONFIG_SOURCE/$config_name"
  local target_path="$SCRIPT_DIR/$config_name"
  
  if [ -d "$source_path" ]; then
    sync_config "$config_name"
  else
    echo -e "${RED}Config not found in ~/.config: $config_name${NC}"
    echo -e "${YELLOW}Available configs in ~/.config: $(ls -1 "$CONFIG_SOURCE" | tr '\n' ' ')${NC}"
    return 1
  fi
}

# Function to list available configs
list_configs() {
  echo -e "${BLUE}Available configurations in ~/.config:${NC}"
  for dir in $(ls -1 "$CONFIG_SOURCE"); do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
      echo "  - $dir (syncable)"
    else
      echo "  - $dir (not in dotfiles repo)"
    fi
  done
}

# Function to check for changes
check_changes() {
  echo -e "${BLUE}Checking for changes...${NC}"
  
  config_dirs=$(ls -1 "$SCRIPT_DIR" | grep -v -E '^(scripts|README\.md|install\.sh|sync\.sh|\.gitignore)$')
  
  for dir in $config_dirs; do
    if [ -d "$CONFIG_SOURCE/$dir" ]; then
      if ! diff -r "$CONFIG_SOURCE/$dir" "$SCRIPT_DIR/$dir" >/dev/null 2>&1; then
        echo -e "${YELLOW}Changes detected in $dir${NC}"
      else
        echo -e "${GREEN}No changes in $dir${NC}"
      fi
    else
      echo -e "${RED}$dir not found in ~/.config${NC}"
    fi
  done
}

# Show usage
show_usage() {
  echo "Usage: $0 [OPTION] [CONFIG_NAME]"
  echo ""
  echo "Options:"
  echo "  sync [CONFIG_NAME]     Sync all configurations or specific one"
  echo "  list                   List available configurations"
  echo "  check                  Check for changes without syncing"
  echo "  help                   Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 sync                # Sync all configurations"
  echo "  $0 sync hyprland       # Sync only hyprland config"
  echo "  $0 check               # Check for changes"
}

# Main script logic
case "$1" in
  sync)
    if [ -z "$2" ]; then
      sync_all_configs
    else
      sync_specific_config "$2"
    fi
    ;;
  list)
    list_configs
    ;;
  check)
    check_changes
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
