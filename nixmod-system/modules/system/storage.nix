{ ... }:

{
  # Mount removable drives without root; udiskie (Home Manager, nikmen-home.nix) automounts
  # them to /run/media/nikmen/<label>.
  services.udisks2.enable = true;
}
