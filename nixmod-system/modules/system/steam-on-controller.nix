# Start Steam when a gamepad appears (udev → user's systemd → short script).
# Wayland: add the exec-once line in hyprland.conf so systemd --user gets WAYLAND_DISPLAY.

{ config, lib, pkgs, ... }:

let
  cfg = config.programs.steam;
  steamCtrl = config.services.steamOnController;
  steamBin = "${cfg.package}/bin/steam";

  launchSteam = pkgs.writeShellScript "steam-on-controller-launch" ''
    set -eu
    runtime="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    mkdir -p "$runtime"
    exec {fd}>"$runtime/steam-on-controller.lock"
    ${pkgs.util-linux}/bin/flock -n "$fd" || exit 0
    ${lib.escapeShellArg steamBin} &
  '';

  udevTrigger = pkgs.writeShellScript "steam-on-controller-udev" ''
    set -eu
    user=${lib.escapeShellArg steamCtrl.user}
    uid=$(${pkgs.coreutils}/bin/id -u "$user" 2>/dev/null) || exit 0
    rt="/run/user/$uid"
    [ -S "$rt/bus" ] || exit 0

    exec {fd}>"/run/steam-on-controller-udev.lock"
    ${pkgs.util-linux}/bin/flock -n "$fd" || exit 0
    ${pkgs.coreutils}/bin/sleep 0.3

    ${pkgs.util-linux}/bin/runuser -u "$user" -- \
      env XDG_RUNTIME_DIR="$rt" \
          DBUS_SESSION_BUS_ADDRESS="unix:path=$rt/bus" \
          ${pkgs.systemd}/bin/systemctl --user start --no-block steam-on-controller.service
  '';
in
{
  options.services.steamOnController = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "nikmen";
      description = ''
        User that must be logged in (graphical session) for Steam to start.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="input", ENV{ID_INPUT_JOYSTICK}=="1", RUN+="${udevTrigger}"
    '';

    systemd.user.services.steam-on-controller = {
      description = "Open Steam when a game controller is connected";
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        TimeoutStartSec = "120";
        ExecStart = "${launchSteam}";
        # Filled after Hyprland (or other compositor) runs dbus-update-activation-environment --systemd …
        PassEnvironment = [
          "WAYLAND_DISPLAY"
          "DISPLAY"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_TYPE"
          "XAUTHORITY"
        ];
      };
    };
  };
}
