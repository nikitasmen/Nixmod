#!/usr/bin/env bash

# NixMod Dotfiles Management Script
# This script handles installation, syncing, and management of user dotfiles

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
DOTFILES_DIR="$REPO_ROOT/nixmod-dotfiles"
CONFIG_TARGET="$HOME/.config"

# Print header
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}   NixMod Dotfiles Manager     ${NC}"
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
    config_dirs=$(ls -1 "$DOTFILES_DIR" | grep -v -E '^(scripts|README\.md|\.gitignore)$')
    
    # Counter for successful installations
    local success_count=0
    local total_count=0
    
    # Process each config directory
    for dir in $config_dirs; do
        ((total_count++))
        source_path="$DOTFILES_DIR/$dir"
        target_path="$CONFIG_TARGET/$dir"
        
        symlink_config "$source_path" "$target_path" "$dir" && ((success_count++))
    done
    
    echo -e "${GREEN}Successfully installed $success_count of $total_count configurations${NC}"
}

# Function to install specific config
install_specific_config() {
    local config_name="$1"
    local source_path="$DOTFILES_DIR/$config_name"
    local target_path="$CONFIG_TARGET/$config_name"
    
    if [ -d "$source_path" ]; then
        symlink_config "$source_path" "$target_path" "$config_name"
        echo -e "${GREEN}Successfully installed $config_name configuration${NC}"
    else
        echo -e "${RED}Config not found: $config_name${NC}"
        echo -e "${YELLOW}Available configs: $(ls -1 "$DOTFILES_DIR" | grep -v -E '^(scripts|README\.md|\.gitignore)$' | tr '\n' ' ')${NC}"
        return 1
    fi
}

# Function to sync a config directory
sync_config() {
    local config_name="$1"
    local source_path="$CONFIG_TARGET/$config_name"
    local target_path="$DOTFILES_DIR/$config_name"
    
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
    echo -e "${BLUE}Syncing all configurations from $CONFIG_TARGET${NC}"
    
    # Get list of config directories that exist in both source and target
    config_dirs=$(ls -1 "$DOTFILES_DIR" | grep -v -E '^(scripts|README\.md|\.gitignore)$')
    
    # Counter for successful syncs
    local success_count=0
    local total_count=0
    
    # Process each config directory
    for dir in $config_dirs; do
        if [ -d "$CONFIG_TARGET/$dir" ]; then
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
    local source_path="$CONFIG_TARGET/$config_name"
    local target_path="$DOTFILES_DIR/$config_name"
    
    if [ -d "$source_path" ]; then
        sync_config "$config_name"
    else
        echo -e "${RED}Config not found in ~/.config: $config_name${NC}"
        echo -e "${YELLOW}Available configs in ~/.config: $(ls -1 "$CONFIG_TARGET" | tr '\n' ' ')${NC}"
        return 1
    fi
}

# Function to check for changes
check_changes() {
    echo -e "${BLUE}Checking for changes...${NC}"
    
    config_dirs=$(ls -1 "$DOTFILES_DIR" | grep -v -E '^(scripts|README\.md|\.gitignore)$')
    
    for dir in $config_dirs; do
        if [ -d "$CONFIG_TARGET/$dir" ]; then
            if ! diff -r "$CONFIG_TARGET/$dir" "$DOTFILES_DIR/$dir" >/dev/null 2>&1; then
                echo -e "${YELLOW}Changes detected in $dir${NC}"
            else
                echo -e "${GREEN}No changes in $dir${NC}"
            fi
        else
            echo -e "${RED}$dir not found in ~/.config${NC}"
        fi
    done
}

# Function to list available configs
list_configs() {
    echo -e "${BLUE}Available configurations:${NC}"
    for dir in $(ls -1 "$DOTFILES_DIR" | grep -v -E '^(scripts|README\.md|\.gitignore)$'); do
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
    find "$DOTFILES_DIR" -type f \( -name "*.conf" -o -name "*.json" -o -name "*.toml" -o -name "*.sh" \) -exec sed -i "s|$old_user_path|$new_user_path|g" {} \;
    
    echo -e "${GREEN}Path update completed${NC}"
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
    done < <(find "$DOTFILES_DIR" -maxdepth 1 -type d -print0)
    
    # Check if any directories were found
    if [ ${#config_apps[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠ No configuration directories found in nixmod-dotfiles${NC}"
        echo -e "${YELLOW}Make sure the nixmod-dotfiles directory contains configuration folders.${NC}"
        return 1
    fi
    
    # Check individual application symlinks
    echo -e "\n${BLUE}Application Symlink Status:${NC}"
    local linked_count=0
    local total_count=${#config_apps[@]}
    
    for app in "${config_apps[@]}"; do
        local target_path="$HOME/.config/$app"
        local source_path="$DOTFILES_DIR/$app"
        
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
        echo -e "${YELLOW}⚠ Some dotfiles are not linked. Run 'install' to fix.${NC}"
    else
        echo -e "${RED}✗ No dotfiles are linked. Run 'install' to install.${NC}"
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [CONFIG_NAME]"
    echo ""
    echo "Commands:"
    echo "  install [CONFIG_NAME]  Install all configurations or specific one"
    echo "  sync [CONFIG_NAME]     Sync all configurations or specific one"
    echo "  list                   List available configurations"
    echo "  status                 Check dotfiles status"
    echo "  check                  Check for changes without syncing"
    echo "  update-paths [PATH]    Update hardcoded paths (default: \$HOME)"
    echo "  help                   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 install             # Install all configurations"
    echo "  $0 install hyprland    # Install only hyprland config"
    echo "  $0 sync                # Sync all configurations"
    echo "  $0 sync hyprland       # Sync only hyprland config"
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
    status)
        check_dotfiles_status
        ;;
    check)
        check_changes
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
