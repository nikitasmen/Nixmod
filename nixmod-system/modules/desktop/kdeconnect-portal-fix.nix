# KDE Connect remote input (mouse/keyboard control from phone) needs the
# xdg-desktop-portal RemoteDesktop interface, which neither
# xdg-desktop-portal-hyprland nor -gtk implement. This bridges it via
# zwlr_virtual_pointer_v1 / zwp_virtual_keyboard_v1.
# https://github.com/gfhdhytghd/hypr-kdeconnect-fix

{ config, pkgs, lib, ... }:

let
  hyprKdeConnectPortal = pkgs.stdenv.mkDerivation {
    pname = "hypr-kdeconnect-portal";
    version = "unstable-2026-09-07";

    src = pkgs.fetchFromGitHub {
      owner = "gfhdhytghd";
      repo = "hypr-kdeconnect-fix";
      rev = "0bc47e676ae2d6964cec4020be9966bbe85985e6";
      hash = "sha256-s8hWpEIyWpwW9w8t80Byqp+8jG0ChddtbDB7eJ/7ebA=";
    };

    nativeBuildInputs = with pkgs; [
      cmake
      pkg-config
      wayland-scanner
      qt6.wrapQtAppsHook
    ];

    buildInputs = with pkgs; [
      qt6.qtbase
      wayland
      libxkbcommon
      libei
    ];

    meta = with lib; {
      description = "xdg-desktop-portal RemoteDesktop backend bridging KDE Connect input on wlroots compositors";
      homepage = "https://github.com/gfhdhytghd/hypr-kdeconnect-fix";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };
in {
  xdg.portal.extraPortals = [ hyprKdeConnectPortal ];

  # Only RemoteDesktop is redirected here; ScreenCast/Screenshot/GlobalShortcuts
  # keep resolving through hyprland/gtk via the existing common.default order.
  xdg.portal.config.common."org.freedesktop.impl.portal.RemoteDesktop" = [ "hypr-kdeconnect" ];
}
