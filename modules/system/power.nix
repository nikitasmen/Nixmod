{ config, pkgs, ... }:

{
  # TLP for power management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      # Battery charging thresholds
      START_CHARGE_THRESH_BAT0 = 40; # Start charging when below 40%
      STOP_CHARGE_THRESH_BAT0 = 90;  # Stop charging when above 90%
    };
  };
}
