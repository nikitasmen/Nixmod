{ config, pkgs, lib,  ... }:

{
   
  #Enable OpenGl
  hardware.graphics = {
  enable = true; 
  }; 

  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true; 
    
    open = true;
    
    prime = {
      intelBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
      offload.enable = true; 
      offload.enableOffloadCmd = true; 
    };
    package = config.boot.kernelPackages.nvidiaPackages.stable; 
  };
} 
