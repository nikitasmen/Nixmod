# When a game controller is plugged in, start Steam in the graphical user's session.
#
# SYSTEMD_USER_WANTS on joystick evdev nodes is unreliable (seat/uaccess), so we use
# udev RUN+= and start the user unit via that user's session D-Bus socket.

{ config, lib, pkgs, ... }:

let
  cfg = config.programs.steam;
  steamCtrl = config.services.steamOnController;
  steamBin = "${cfg.package}/bin/steam";

  # Built with "…" lines so |, <, and bash read -d '' do not interact badly with Nix '' strings.
  launchSteam = pkgs.writeShellScript "steam-on-controller-launch" (
    lib.concatStringsSep "\n" [
      "set -eu"
      "# User units often lack WAYLAND_DISPLAY/DISPLAY (not imported into systemd --user)."
      "# Copy display-related vars from the running compositor so Steam can open a window."
      "uid=$(${pkgs.coreutils}/bin/id -u)"
      "# Match cmdline (Nix wraps compositors; -x often misses Hyprland)."
      "for name in Hyprland hyprland sway swayfx gnome-shell; do"
      "  pid=$(${pkgs.procps}/bin/pgrep -u \"\$uid\" -f \"\$name\" 2>/dev/null | ${pkgs.coreutils}/bin/head -n1 || true)"
      "  [ -n \"\$pid\" ] || continue"
      "  envfile=\"/proc/\$pid/environ\""
      "  [ -r \"\$envfile\" ] || continue"
      "  # Pipe would run while in a subshell — exports would not reach steam. Use process substitution."
      "  while IFS= read -r var; do"
      "    case \"\$var\" in"
      "      WAYLAND_DISPLAY=*|DISPLAY=*|XAUTHORITY=*|XDG_SESSION_TYPE=*|XDG_CURRENT_DESKTOP=*|SDL_VIDEODRIVER=*|QT_QPA_PLATFORM=*|GDK_BACKEND=*)"
      "        export \"\$var\""
      "        ;;"
      "    esac"
      "  done < <(${pkgs.perl}/bin/perl -0pe 's/\\x00/\\n/g' \"\$envfile\")"
      "  break"
      "done"
      "if [ -z \"\${WAYLAND_DISPLAY:-}\" ] && [ -z \"\${DISPLAY:-}\" ]; then"
      "  shopt -s nullglob || true"
      "  for wl in /run/user/\$uid/wayland-*; do"
      "    [ -S \"\$wl\" ] || continue"
      "    export WAYLAND_DISPLAY=\${wl##*/}"
      "    break"
      "  done"
      "fi"
      "runtime=\"\${XDG_RUNTIME_DIR:-/run/user/\$uid}\""
      "mkdir -p \"\$runtime\""
      "lock=\"\$runtime/steam-on-controller.lock\""
      "exec {lock_fd}>\"\$lock\""
      "if ! ${pkgs.util-linux}/bin/flock -n \"\$lock_fd\"; then"
      "  exit 0"
      "fi"
      "nohup ${lib.escapeShellArg steamBin} </dev/null >/dev/null 2>&1 &"
    ]
  );

  # Invoked by udev (root). Starts the oneshot in the target user's systemd --user.
  udevTrigger = pkgs.writeShellScript "steam-on-controller-udev" ''
    set -eu
    user=${lib.escapeShellArg steamCtrl.user}
    uid=$(${pkgs.coreutils}/bin/id -u "$user" 2>/dev/null) || exit 0
    rt="/run/user/$uid"
    [ -S "$rt/bus" ] || exit 0

    # One physical pad often creates several evdev nodes; coalesce bursts.
    exec {fd}>"/run/steam-on-controller-udev.lock"
    if ! ${pkgs.util-linux}/bin/flock -n "$fd"; then
      exit 0
    fi
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
        Account whose active login session (graphical) should receive Steam when a
        controller is plugged in. Requires /run/user/<uid>/bus (logged in).
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
      };
    };
  };
}
