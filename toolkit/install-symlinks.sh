#!/usr/bin/env bash

# Install NixMod symlink in /usr/local/bin for easy access

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root${NC}"
   echo "Try: sudo $0"
   exit 1
fi

# Create symlink for nixmod.sh
echo "Creating symlink for nixmod.sh in /usr/local/bin..."
ln -sf "$SCRIPT_DIR/nixmod.sh" /usr/local/bin/nixmod

# Create symlink for helper.sh
echo "Creating symlink for helper.sh in /usr/local/bin..."
ln -sf "$SCRIPT_DIR/helper.sh" /usr/local/bin/nixmod-helper

echo -e "${GREEN}Symlinks created successfully!${NC}"
echo "You can now use 'nixmod' and 'nixmod-helper' commands from anywhere."

exit 0
