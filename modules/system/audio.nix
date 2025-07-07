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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Audio related packages
  environment.systemPackages = with pkgs; [
    pavucontrol  # Sound control panel
    playerctl    # Music player controller
    cava         # Audio Visualizer
  ];
  
  # Bluetooth configuration
  services.blueman.enable = true;
}
