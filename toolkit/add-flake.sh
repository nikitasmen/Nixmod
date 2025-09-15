#!/usr/bin/env bash

# Helper script to add new flake inputs to the main flake.nix

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
MODULE_PATH=""

print_usage() {
  echo "Usage: nixmod.sh add-flake [options]"
  echo ""
  echo "Options:"
  echo "  -n, --name NAME          Name of the flake input (required)"
  echo "  -u, --url URL            URL of the flake repository (required)"
  echo "  -d, --description DESC   Short description of the flake"
  echo "  -m, --module PATH        Path to the module that will use this flake"
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

add_flake_to_inputs() {
  local flake_nix="$NIXMOD_ROOT/nixmod-system/flake.nix"
  
  echo_info "Adding $FLAKE_NAME to flake.nix inputs"
  
  # Create temporary file
  local temp_file=$(mktemp)
  
  # Create the flake input definition
  local flake_def="    # ${FLAKE_DESCRIPTION:-$FLAKE_NAME input}\n    $FLAKE_NAME = {\n      url = \"$FLAKE_URL\";"
  
  if [[ "$NOT_A_FLAKE" = true ]]; then
    flake_def="$flake_def\n      flake = false;"
  fi
  
  if [[ "$FLAKE_NIXPKGS_FOLLOWS" = true ]]; then
    flake_def="$flake_def\n      inputs.nixpkgs.follows = \"nixpkgs\";"
  fi
  
  flake_def="$flake_def\n    };"
  
  # Insert the flake input definition before the closing } of the inputs section
  awk -v flake_def="$flake_def" '
    /^  inputs = {/,/^  };/ {
      if (/^  };/) {
        print flake_def
        print $0
        next
      }
    }
    {print}
  ' "$flake_nix" > "$temp_file"
  
  # Replace the original file with the modified content
  mv "$temp_file" "$flake_nix"
  
  echo_success "Added $FLAKE_NAME to flake.nix inputs"
  
  # Create a module example if module path is provided
  if [[ -n "$MODULE_PATH" ]]; then
    create_module
  else
    echo_info "Now add the module to your flake outputs:"
    echo ""
    echo_code "outputs = { self, nixpkgs, $FLAKE_NAME, ... }@inputs:"
    echo_code "  let"
    echo_code "    # Create module for $FLAKE_NAME"
    echo_code "    ${FLAKE_NAME}Module = {"
    echo_code "      module = { config, ... }: {"
    echo_code "        imports = [ ./path/to/your/module.nix ];"
    echo_code "        _module.args.${FLAKE_NAME} = $FLAKE_NAME;"
    echo_code "      };"
    echo_code "    };"
    echo_code "  in {"
    echo_code "    # Add to modules list"
    echo_code "    nixosConfigurations.nixos = lib.nixosSystem {"
    echo_code "      modules = ["
    echo_code "        # ..."
    echo_code "        ${FLAKE_NAME}Module.module"
    echo_code "      ];"
    echo_code "    };"
    echo_code "  };"
  fi
}

create_module() {
  echo_info "Creating module for $FLAKE_NAME at $MODULE_PATH"
  
  # Create directory if it doesn't exist
  mkdir -p "$(dirname "$MODULE_PATH")"
  
  # Create the module file
  cat > "$MODULE_PATH" << EOF
{ config, pkgs, lib, $FLAKE_NAME ? null, ... }:

# ${FLAKE_DESCRIPTION:-Module for $FLAKE_NAME}
{
  # Your configuration for $FLAKE_NAME goes here
  # Example:
  # programs.$FLAKE_NAME.enable = true;
}
EOF

  echo_success "Created module at $MODULE_PATH"
  
  echo_info "Now add the module to your flake outputs:"
  echo ""
  echo_code "outputs = { self, nixpkgs, $FLAKE_NAME, ... }@inputs:"
  echo_code "  let"
  echo_code "    # Create module for $FLAKE_NAME"
  echo_code "    ${FLAKE_NAME}Module = {"
  echo_code "      module = { config, ... }: {"
  echo_code "        imports = [ $MODULE_PATH ];"
  echo_code "        _module.args.${FLAKE_NAME} = $FLAKE_NAME;"
  echo_code "      };"
  echo_code "    };"
  echo_code "  in {"
  echo_code "    # Add to modules list"
  echo_code "    nixosConfigurations.nixos = lib.nixosSystem {"
  echo_code "      modules = ["
  echo_code "        # ..."
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
    -m|--module) MODULE_PATH="$2"; shift ;;
    -f|--follows-nixpkgs) FLAKE_NIXPKGS_FOLLOWS=true ;;
    -N|--not-a-flake) NOT_A_FLAKE=true ;;
    -h|--help) print_usage; exit 0 ;;
    *) echo_error "Unknown parameter: $1"; print_usage; exit 1 ;;
  esac
  shift
done

# Validate and process inputs
validate_inputs
add_flake_to_inputs
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
