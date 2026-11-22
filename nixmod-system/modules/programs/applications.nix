{ config, pkgs, nixmod, lib, ... }:

{
  # Enable Firefox
  programs.firefox.enable = true;
  # Block every AI feature (chatbot, smart window, link previews, smart tab
  # groups, PDF alt-text, speech recognition, translations) and lock it so the
  # settings page can't turn it back on.
  programs.firefox.policies.AIControls.Default = { Value = "blocked"; Locked = true; };
  # Stop the on-device ML engine from loading or downloading models at all
  programs.firefox.preferences."browser.ml.enable" = false;
  programs.firefox.preferencesStatus = "locked";
  # Firefox enables speech-dispatcher by default (~1 GB of voices); not needed
  services.speechd.enable = false;
  
  # Other applications
  # Package list: applications.packages.json (edited by nixmod-gui and `nixmod.sh packages`)
  # Not installed: stremio (insecure dependencies), webcord and logseq (discord-ptb is used
  # instead; not Electron-dependent), neofetch (replaced by fastfetch).
  environment.systemPackages = nixmod.readPackages ./applications.packages.json;
}
