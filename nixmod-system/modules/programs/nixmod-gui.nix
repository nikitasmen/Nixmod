{ config, pkgs, lib, ... }:

# NixMod GUI (toolkit/nixmod-gui.py): GTK4 app for adding/removing packages
# (the modules' *.packages.json files) and running toolkit/nixmod.sh actions.
let
  python = pkgs.python3.withPackages (p: [ p.pygobject3 ]);

  nixmod-gui = pkgs.stdenvNoCC.mkDerivation {
    pname = "nixmod-gui";
    version = "1.0";
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.wrapGAppsHook4 pkgs.gobject-introspection ];
    buildInputs = [ pkgs.gtk4 ];
    desktopItem = pkgs.makeDesktopItem {
      name = "nixmod-gui";
      desktopName = "NixMod";
      comment = "Manage packages and rebuild the NixMod configuration";
      exec = "nixmod-gui";
      icon = "nix-snowflake";
      categories = [ "System" "Settings" ];
      startupWMClass = "com.nikmen.NixmodGui";
    };
    installPhase = ''
      install -Dm755 ${../../../toolkit/nixmod-gui.py} $out/bin/nixmod-gui
      substituteInPlace $out/bin/nixmod-gui \
        --replace-fail '#!/usr/bin/env python3' '#!${python}/bin/python3'
      install -Dm644 $desktopItem/share/applications/* -t $out/share/applications
    '';
    # The store copy can't locate the checkout; point it at the live repo
    # (same absolute path the nvim mkOutOfStoreSymlink uses).
    preFixup = ''
      gappsWrapperArgs+=(--set-default NIXMOD_REPO "${config.users.users.nikmen.home}/Documents/Nixmod")
    '';
  };
in
{
  environment.systemPackages = [ nixmod-gui ];
}
