# TypeScript/Node.js Playwright dev shell (no Python)
# Use: nix develop -f nixmod-system/playwrightConfig.nix
# Then: npm install && npx playwright test

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.nodejs
    pkgs.playwright-driver.browsers  # Browser binaries only (no Python)
    pkgs.glib
    pkgs.nss
    pkgs.nspr
    pkgs.dbus
    pkgs.atk
    pkgs.atkmm
    pkgs.expat
    pkgs.at-spi2-core
    pkgs.libp11
    pkgs.systemd
    pkgs.alsa-lib
    pkgs.gtk3
    pkgs.cairo
    pkgs.pango
    pkgs.fontconfig
    pkgs.freetype
  ];

  shellHook = ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
    echo "✅ TypeScript Playwright shell ready"
    echo "   Install: npm install"
    echo "   Run tests: npx playwright test"
    echo "   Match @playwright/test version with nixpkgs playwright-driver (see nixhub.io)"
  '';
}