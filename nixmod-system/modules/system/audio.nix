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
  
  # Audio related packages
  environment.systemPackages = with pkgs; [
    pavucontrol  # Sound control panel
    playerctl    # Music player controller
    cava         # Audio Visualizer
    obs-studio   # OBS studio 
  ];
  
  # Bluetooth configuration
  services.blueman.enable = true;
}
