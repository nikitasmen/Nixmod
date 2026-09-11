# Start Steam when a gamepad appears (udev → user's systemd → short script).
# Hyprland: keep exec-once = dbus-update-activation-environment --systemd … in hyprland.conf

{ config, lib, pkgs, ... }:

let
  cfg = config.programs.steam;
  steamCtrl = config.services.steamOnController;
  steamBin = "${cfg.package}/bin/steam";
  # User units default to a tiny PATH; Steam's launcher shells out to bash, grep, etc.
  steamPath = lib.makeBinPath [
    pkgs.bashInteractive
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gnused
    pkgs.gawk
    cfg.package
  ];

  launchSteam = pkgs.writeShellScript "steam-on-controller-launch" ''
    set -eu
    export PATH="/run/current-system/sw/bin:/run/wrappers/bin:''${PATH}"
    runtime="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    mkdir -p "$runtime"
    exec {fd}>"$runtime/steam-on-controller.lock"
    ${pkgs.util-linux}/bin/flock -n "$fd" || exit 0

    # If dbus-update-activation-environment was never run, try the usual Wayland socket name(s).
    if [ -z "''${WAYLAND_DISPLAY:-}" ] && [ -z "''${DISPLAY:-}" ]; then
      shopt -s nullglob || true
      for wl in "$runtime"/wayland-*; do
        [ -S "$wl" ] || continue
        export WAYLAND_DISPLAY=''${wl##*/}
        break
      done
    fi

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
    # js* covers some pads that lag on ID_INPUT_JOYSTICK; flock dedupes double events.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="input", ENV{ID_INPUT_JOYSTICK}=="1", RUN+="${udevTrigger}"
      ACTION=="add", SUBSYSTEM=="input", KERNEL=="js[0-9]*", RUN+="${udevTrigger}"
    '';

    systemd.user.services.steam-on-controller = {
      description = "Open Steam when a game controller is connected";
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        TimeoutStartSec = "120";
        ExecStart = "${launchSteam}";
        # Critical: default control-group kills background steam when the shell exits.
        KillMode = "none";
        Environment = [ "PATH=${steamPath}" ];
        PassEnvironment = [
          "WAYLAND_DISPLAY"
          "DISPLAY"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_TYPE"
          "XAUTHORITY"
          "HOME"
          "USER"
          "LOGNAME"
          "DBUS_SESSION_BUS_ADDRESS"
        ];
      };
    };
  };
}
