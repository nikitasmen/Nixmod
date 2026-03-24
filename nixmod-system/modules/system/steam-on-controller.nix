# When a game controller is plugged in, start Steam in the logged-in user's session.
# Uses udev ID_INPUT_JOYSTICK + systemd user units (see systemd.device(5) SYSTEMD_USER_WANTS).

{ config, lib, pkgs, ... }:

let
  cfg = config.programs.steam;
  steamBin = "${cfg.package}/bin/steam";
  launchSteam = pkgs.writeShellScript "steam-on-controller-launch" ''
    set -eu
    runtime="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    mkdir -p "$runtime"
    lock="$runtime/steam-on-controller.lock"
    exec {lock_fd}>"$lock"
    if ! flock -n "$lock_fd"; then
      exit 0
    fi
    nohup ${lib.escapeShellArg steamBin} </dev/null >/dev/null 2>&1 &
  '';
in
lib.mkIf cfg.enable {
  services.udev.extraRules = ''
    # Debounce: many controllers expose several joystick nodes; user service uses flock.
    ACTION=="add", SUBSYSTEM=="input", ENV{ID_INPUT_JOYSTICK}=="1", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="steam-on-controller.service"
  '';

  systemd.user.services.steam-on-controller = {
    description = "Open Steam when a game controller is connected";
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
      # Steam may take a moment to detach from the wrapper script
      TimeoutStartSec = "120";
      ExecStart = "${launchSteam}";
    };
  };
}
