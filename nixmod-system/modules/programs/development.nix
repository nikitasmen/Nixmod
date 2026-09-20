{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  # Git, bat, delta config in dotfiles: ~/.config/git/config
  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    git          # Version control
    delta        # Better git diff
    lazygit      # Git TUI
    bat          # cat with syntax highlighting
    glow         # Markdown viewer for the terminal
    eza          # Better ls
    docker       # Container platform
    helix        # Text editor
    neovim       # Code editor (vim + Lua config)
    tmux         # Terminal multiplexer
    tree         # Directory display
    findutils    # File search utilities
    fd           # Faster find alternative
    ripgrep      # Fast grep alternative (needed by Neovim Telescope live_grep/grep_string)
    tealdeer     # Fast tldr implementation
    coreutils    # Basic utilities
    gcc          # C compiler (needed by Neovim Treesitter to build parsers)
    tree-sitter  # `tree-sitter` CLI (needed by Neovim Treesitter to build parsers)
    nixfmt       # Nix formatter (`nixfmt`), used by Neovim conform.nvim + nixd
    statix       # Nix linter, used by Neovim nvim-lint
    nixd         # Nix LSP, used by Neovim (NOT in Mason's registry, so it's declared here instead)
    nodejs       # needed by Neovim Mason to install npm-based LSP servers/formatters
                 # (ts_ls, html, cssls, tailwindcss, jsonls, prettier(d), eslint_d)
    python3      # needed by Neovim Mason to install pyright
    unzip        # needed by Neovim Mason to install some tools (e.g. stylua)
    # xclip      # Clipboard controll X11 based
    wl-clipboard # Clipboard controll Waylad based
    clipse       # Clipboard manager 
    scc          # Code counter
    p7zip        # zipping tool

    claude-code
  ];
}
