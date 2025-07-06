#!/usr/bin/env bash

# Helper script to create new flake modules for Nixmod

set -e

# Source helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helper.sh"

# Default values
FLAKE_NAME=""
FLAKE_URL=""
FLAKE_NIXPKGS_FOLLOWS=false
NOT_A_FLAKE=false
FLAKE_DESCRIPTION=""

print_usage() {
  echo "Usage: nixmod.sh add-flake [options]"
  echo ""
  echo "Options:"
  echo "  -n, --name NAME          Name of the flake module (required)"
  echo "  -u, --url URL            URL of the flake repository (required)"
  echo "  -d, --description DESC   Short description of the flake"
  echo "  -f, --follows-nixpkgs    Make the flake follow the main nixpkgs input"
  echo "  -N, --not-a-flake        Mark as not a flake (for repositories without flake.nix)"
  echo "  -h, --help               Show this help message"
}

validate_inputs() {
  if [[ -z "$FLAKE_NAME" ]]; then
    echo_error "Flake name is required"
    print_usage
    exit 1
  fi
  
  if [[ -z "$FLAKE_URL" ]]; then
    echo_error "Flake URL is required"
    print_usage
    exit 1
  fi
}

create_flake_module() {
  local module_dir="$NIXMOD_ROOT/flakes/$FLAKE_NAME"
  
  # Check if module already exists
  if [[ -d "$module_dir" ]]; then
    echo_error "A flake module named '$FLAKE_NAME' already exists"
    exit 1
  fi
  
  echo_info "Creating flake module: $FLAKE_NAME"
  
  # Create directory
  mkdir -p "$module_dir"
  
  # Generate default.nix content
  local not_flake_line=""
  if [[ "$NOT_A_FLAKE" = true ]]; then
    not_flake_line="      flake = false; # This is not a flake"
  fi
  
  local follows_nixpkgs_line=""
  if [[ "$FLAKE_NIXPKGS_FOLLOWS" = true ]]; then
    follows_nixpkgs_line="      inputs.nixpkgs.follows = \"nixpkgs\";"
  fi
  
  cat > "$module_dir/default.nix" << EOF
# $FLAKE_DESCRIPTION
{
  # Define ${FLAKE_NAME} inputs
  inputs = {
    ${FLAKE_NAME} = {
      url = "${FLAKE_URL}";
${not_flake_line}
${follows_nixpkgs_line}
    };
  };
  
  # Define the output function that creates the module
  outputs = inputs@{ ${FLAKE_NAME}, ... }: {
    # This function returns a NixOS module
    module = { config, pkgs, lib, ... }: {
      # Your module configuration goes here
      # For example:
      # imports = [ ${FLAKE_NAME}.nixosModules.default ];
      
      # Or direct configuration:
      # programs.${FLAKE_NAME}.enable = true;
    };
    
    # Expose any other useful outputs from the flake
    # nixosModules = ${FLAKE_NAME}.nixosModules or {};
    # packages = ${FLAKE_NAME}.packages or {};
  };
}
EOF
  
  echo_success "Created flake module in $module_dir/default.nix"
  echo_info "Now you need to:"
  echo "  1. Edit the module to configure how it should be used"
  echo "  2. Update your main flake.nix to include this module"
  echo ""
  echo_code "inputs = {"
  echo_code "  # ...existing inputs"
  echo_code "  ${FLAKE_NAME} = (import ./flakes/${FLAKE_NAME}).inputs.${FLAKE_NAME};"
  echo_code "};"
  echo ""
  echo_code "outputs = { self, nixpkgs, ... }@inputs: "
  echo_code "  let"
  echo_code "    # ...existing setup"
  echo_code "    ${FLAKE_NAME}Module = (import ./flakes/${FLAKE_NAME}).outputs inputs;"
  echo_code "  in {"
  echo_code "    nixosConfigurations.nixos = lib.nixosSystem {"
  echo_code "      # ...existing config"
  echo_code "      modules = ["
  echo_code "        # ...existing modules"
  echo_code "        ${FLAKE_NAME}Module.module"
  echo_code "      ];"
  echo_code "    };"
  echo_code "  };"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -n|--name) FLAKE_NAME="$2"; shift ;;
    -u|--url) FLAKE_URL="$2"; shift ;;
    -d|--description) FLAKE_DESCRIPTION="$2"; shift ;;
    -f|--follows-nixpkgs) FLAKE_NIXPKGS_FOLLOWS=true ;;
    -N|--not-a-flake) NOT_A_FLAKE=true ;;
    -h|--help) print_usage; exit 0 ;;
    *) echo_error "Unknown parameter: $1"; print_usage; exit 1 ;;
  esac
  shift
done

# Validate and process inputs
validate_inputs
create_flake_module
