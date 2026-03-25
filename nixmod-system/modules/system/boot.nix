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
      # External USB keyboards often do not work with GRUB’s graphical terminal (gfxterm)
      # on UEFI; the EFI “console” input path usually includes USB HID. This forces the
      # classic text console for the menu (no themed background). Remove if you dislike it.
      extraConfig = ''
        terminal_input console
        terminal_output console
      '';
    };

    systemd-boot.enable = false;

    # Seconds before default entry boots; increase if you need more time to read the list.
    timeout = 10;
  };
}
