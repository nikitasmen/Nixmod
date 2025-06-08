{ config, pkgs, lib,  ... }:

{
  #Enable OpenGl
  hardware.graphics = {
  enable = true; 
  }; 

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    open = true;
    
    prime = {
      intelBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
