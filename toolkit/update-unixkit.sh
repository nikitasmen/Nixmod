#!/usr/bin/env bash

# Script to update UnixKit and rebuild NixOS
# This script ensures you always get the latest UnixKit version

set -e

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Updating UnixKit to latest version...${NC}"

# Step 1: Check if we're in a Git repository
if [ ! -d ".git" ]; then
  echo -e "${YELLOW}Warning: Not in a git repository root. Commands may not work as expected.${NC}"
fi

# Step 2: Check if flake.lock exists
if [ -f "flake.lock" ]; then
  echo -e "${BLUE}Found existing flake.lock, updating UnixKit input...${NC}"
  nix flake lock --update-input unixkit
else
  echo -e "${BLUE}No flake.lock found, creating initial lock file...${NC}"
  nix flake lock
fi

# Step 3: Build the system with updated inputs
echo -e "${BLUE}Building system with latest UnixKit...${NC}"
sudo nixos-rebuild switch --flake .#nixos

echo -e "${GREEN}System updated with latest UnixKit version!${NC}"

# Step 4: Show the current UnixKit commit hash
echo -e "${BLUE}Current UnixKit commit:${NC}"
if grep -q "unixkit" flake.lock; then
  UNIXKIT_REV=$(grep -A 5 '"unixkit"' flake.lock | grep '"rev"' | cut -d'"' -f4)
  echo -e "${GREEN}${UNIXKIT_REV}${NC}"
  
  # Display first line of commit message if we can
  echo -e "${BLUE}Commit message:${NC}"
  if command -v gh &> /dev/null; then
    gh api repos/nikitasmen/UnixKit/commits/${UNIXKIT_REV} --jq '.commit.message' | head -1
  else
    echo -e "${YELLOW}Install GitHub CLI (gh) to see commit messages${NC}"
  fi
else
  echo -e "${YELLOW}Unable to find UnixKit revision in flake.lock${NC}"
fi

echo -e "${BLUE}Done!${NC}"
