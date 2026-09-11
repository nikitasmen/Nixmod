{ config, lib, ... }:

{
  options.nixmod.mainUser = lib.mkOption {
    type = lib.types.str;
    default = "nikmen";
    description = "Main user account for shell and other user-specific config";
  };

  imports = [
    ./nikmen.nix
  ];
}
