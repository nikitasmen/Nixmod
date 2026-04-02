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
    jack.enable = true;
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
  programs.obs-studio = {
    enable = true;

    # Optional! Nvidia Hardware acceleration 
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true; 
      }
    ); 

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];    
  };
  
  # Audio related packages (OBS is already installed via programs.obs-studio above)
  environment.systemPackages = with pkgs; [
    pavucontrol  # Sound control panel
    playerctl    # Music player controller
    cava         # Audio Visualizer
  ];
  
  # Bluetooth configuration
  services.blueman.enable = true;

  # Enable UPower for battery reporting (fixes WirePlumber warnings)
  services.upower.enable = true;
}
