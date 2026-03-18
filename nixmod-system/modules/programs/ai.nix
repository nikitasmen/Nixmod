# AI-powered CLI tools: aichat (shell assistant, execute commands), nixai (NixOS help),
# fzf (fuzzy path/command finder), zoxide (smart cd). Uses local Ollama (see hyprland.nix).
{ config, pkgs, lib, inputs ? { }, ... }:

{
  # AI CLI tools - aichat reads paths, executes commands, suggests next steps
  environment.systemPackages = with pkgs; [
    aichat       # Shell assistant: natural language -> commands, -e to execute
    fzf          # Fuzzy finder for paths, history, files
    zoxide       # Smarter cd - learns your paths
  ] ++ lib.optional (inputs ? nix-ai) inputs.nix-ai.packages.${pkgs.system}.default;

  # Zsh with AI-friendly autocomplete (suggestions from history, syntax highlighting)
  programs.zsh = {
    enable = true;
    autosuggestions = {
      enable = true;
      strategy = [ "history" "completion" ];
      highlightStyle = "fg=8";
    };
    syntaxHighlighting.enable = true;
    # Fzf key bindings (Ctrl+R history, Ctrl+T files, Alt+C cd) + zoxide (smart cd)
    interactiveShellInit = ''
      [[ -f ${pkgs.fzf}/share/fzf/key-bindings.zsh ]] && source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      [[ -f ${pkgs.fzf}/share/fzf/completion.zsh ]] && source ${pkgs.fzf}/share/fzf/completion.zsh
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
    '';
  };

  # Use zsh as default shell for the main user
  users.users.${config.nixmod.mainUser}.shell = pkgs.zsh;

  # Shell aliases for AI workflows
  environment.shellAliases = {
    # Natural language -> execute: "ai list large files" or "ai find todos in src/"
    ai = "aichat -e";
  };
}
