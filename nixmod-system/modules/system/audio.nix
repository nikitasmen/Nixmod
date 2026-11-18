{ config, pkgs, ... }:

{
  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true; 
  };

  # Custom WirePlumber policy to prefer internal speakers over ghost devices
  services.pipewire.wireplumber.extraConfig = {
    "10-default-policy" = {
      "wireplumber.settings" = {
        "device.restore-default-targets" = true;
      };
    };
  };

  # Fix for volume keys not working: ensure wireplumber is starting correctly
  systemd.user.services.wireplumber.wantedBy = [ "pipewire.service" ];

  # Enable OBS
    #programs.obs-studio = {
    #enable = true;

    # Optional! Nvidia Hardware acceleration 
    #package = (
    # pkgs.obs-studio.override {
    #   cudaSupport = true; 
    # }
    # ); 

    #plugins = with pkgs.obs-studio-plugins; [
    # wlrobs
    #  obs-backgroundremoval
    #  obs-pipewire-audio-capture
    #  obs-gstreamer
    #  obs-vkcapture
    # ];    
    #};
  
  # Audio related packages (OBS is already installed via programs.obs-studio above)
  environment.systemPackages = with pkgs; [
    pavucontrol  # Sound control panel
    playerctl    # Music player controller
    cava         # Audio Visualizer
  ];

  environment.shellAliases = {
    # Quick command to open audio settings
    pavucontrol = "GDK_BACKEND=x11 pavucontrol";
  };
  # Bluetooth configuration
  services.blueman.enable = true;

  # Auto-connect the SBS E2500 speaker after login (speakers don't reconnect to the host themselves).
  # Retries for ~5 min in case the speaker is switched on after boot.
  systemd.user.services.bt-speaker-autoconnect = {
    description = "Auto-connect SBS E2500 Bluetooth speaker";
    wantedBy = [ "default.target" ];
    after = [ "pipewire.service" "wireplumber.service" ];
    path = [ pkgs.bluez pkgs.gnugrep ];
    script = ''
      mac=00:02:3C:8C:AC:E5
      bluetoothctl trust "$mac" >/dev/null || true  # script runs under set -e
      for _ in $(seq 30); do
        bluetoothctl connect "$mac" >/dev/null || true
        bluetoothctl info "$mac" | grep -q "Connected: yes" && exit 0
        sleep 10
      done
      exit 1
    '';
  };

  # Enable UPower for battery reporting (fixes WirePlumber warnings)
  services.upower.enable = true;
}
