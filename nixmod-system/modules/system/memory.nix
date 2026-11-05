{ ... }:

{
  # No disk swap (hardware-configuration.nix); without this, big rebuilds alongside
  # Docker/Slack hit the global OOM killer, which kills `nix build` mid-switch.
  zramSwap.enable = true;

  # zram lives in RAM, so when it fills the box thrashes into a hard freeze before the
  # kernel OOM killer fires (seen with RPCS3). earlyoom kills the biggest process first.
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # % of RAM
    freeSwapThreshold = 10; # % of swap
    extraArgs = [ "--prefer" "^(rpcs3|xenia_canary)$" "--avoid" "^(Hyprland|\\.Hyprland-wrapp|systemd|greetd)$" ];
  };
}
