# Login shell only. The shell itself (plugins, fzf, zoxide, starship) is
# configured per-user in Home Manager: modules/users/nikmen-home.nix.
{ pkgs, ... }:

{
  # Required at system level when zsh is a login shell (/etc/shells, completions)
  programs.zsh.enable = true;
  users.users.nikmen.shell = pkgs.zsh;
}
