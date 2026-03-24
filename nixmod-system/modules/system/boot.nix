{ config, pkgs, ... }:

{
  # GRUB on EFI: arrow keys / selection often work when systemd-boot’s menu is visible
  # but the firmware console ignores the keyboard (common on laptops).
  boot.loader = {
    efi.canTouchEfiVariables = true;

    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      configurationLimit = 30;
    };

    systemd-boot.enable = false;

    # Seconds before default entry boots; increase if you need more time to read the list.
    timeout = 10;
  };
}
