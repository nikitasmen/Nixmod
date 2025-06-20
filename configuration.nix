# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib,  ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia-configuration.nix
      ./modules/custom/unixkit/deafult.nix
    ];

   # List packages installed in system profile. To search, run:
  nixpkgs.overlays = [
    (import ./overlays/flameshot.nix)
   ]; 
   # Use flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];
  
  # Bootloader.
  boot.loader.grub.enable = false;
  #boot.loader.grub.device = "/dev/nvme0n1";
  #boot.loader.grub.useOSProber = true;
  
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

       #Optional helps save long term battery health
       START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
       STOP_CHARGE_THRESH_BAT0 = 90; # 90 and above it stops charging

      };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  
  # Enable Blueman applet GUI
  services.blueman.enable = true;
   
  # Set your time zone.
  time.timeZone = "Europe/Athens";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "el_GR.UTF-8";
    LC_IDENTIFICATION = "el_GR.UTF-8";
    LC_MEASUREMENT = "el_GR.UTF-8"; 
    LC_MONETARY = "el_GR.UTF-8";
    LC_NAME = "el_GR.UTF-8";
    LC_NUMERIC = "el_GR.UTF-8";
    LC_PAPER = "el_GR.UTF-8";
    LC_TELEPHONE = "el_GR.UTF-8";
    LC_TIME = "el_GR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = false;

  # Services for kdeConnect
  # You may also need this if you want a system tray for KDE Connect
  services.dbus.enable = true;
  # programs.dconf.enable = true;
  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = true;
    publish.addresses = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config = {
      common.default = "wlr";
    };
  }; 
  
  # Optional but recommended for notifications
  # services.mako.enable = true; # or any other notification daemon
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  #
  virtualisation.docker.enable = true; 
  
  users.users.nikmen = {
    isNormalUser = true;
    description = "nikmen";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
    #  thunderbird
    slack # Communicatio
    viber 
    ];
  };

  # Enable automatic login for the user.
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "nikmen";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Install firefox.
  programs.firefox.enable = true;

  # Enable hyprland 
  programs.hyprland.enable = true; 

  programs.hyprlock.enable = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.steam.enable = true;

  # $ nix search wget
  environment.systemPackages = with pkgs; [
 
    # --- Essential Tools ---
    git          # Version control
    #direnv      # Environment variable management, integrates well with VS Code
    tmux         # terminal multiplexer
    tree         # structured dir displayer  
    # wget        # Optional: CLI tool for downloading files
    neofetch     # Optional: System information tool 
    vim          # Optional: Editor for editing configuration.nix
    alacritty 
    flameshot    # Screenshot tool 
    eww          # Widget Sytem
    grim
    slurp 
    playerctl    # Music player controller
    yazi         # File explorer    
    superfile    # File explorer
    ghostty      # Terminal emulator
    # kdeconnect
    fish 
    mako 
    pavucontrol  # Sound Control
    wlogout 
    networkmanager_dmenu   # Network manager
    hyprpaper
    hypridle
    hyprlock
    findutils
    coreutils
    plasma5Packages.kdeconnect-kde    # multiplatform connector 
    kdePackages.kdeconnect-kde
    # --- Development Environment ---
    #vscode       # Visual Studio Code editor
    docker        # Docker Container Application 
    helix         # Helix Text Editor
    
    # --- Browsers ---
    # opera         # Web browser

    kitty        # Hyprland terminal emulator. Required for default config  
    waybar       # Display Server
    # rofi-wayland
    wofi         # Search bar 
    # --- Media ---
    spotify       # Music streaming client
    spicetify-cli # Spotify customize cli tool 
    freetube      # Free youtube alternative
    stremio
    
    # --- Communication --- 
    # discord-ptb
    webcord
  ];
  
  programs.git = { 
    enable = true; 
    config = {  
      user.name = "nikitasmen";
    	user.email = "menounosnikitas@gmail.com";
    };
  }; 

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  fonts.packages = with pkgs; [
   pkgs.nerd-fonts.fira-code
   pkgs.nerd-fonts.jetbrains-mono
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

} 
