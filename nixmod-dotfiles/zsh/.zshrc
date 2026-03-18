# Zsh config - sourced when ZDOTDIR=~/.config/zsh

# Fzf key bindings (Ctrl+R history, Ctrl+T files, Alt+C cd)
[[ -f $(dirname $(command -v fzf 2>/dev/null))/../share/fzf/key-bindings.zsh ]] && source $(dirname $(command -v fzf 2>/dev/null))/../share/fzf/key-bindings.zsh
[[ -f $(dirname $(command -v fzf 2>/dev/null))/../share/fzf/completion.zsh ]] && source $(dirname $(command -v fzf 2>/dev/null))/../share/fzf/completion.zsh

# Zoxide: smart cd
eval "$(zoxide init zsh)" 2>/dev/null

# Prompt: current path in green
PROMPT='%F{green}%~%f %# '

# Aliases
alias ai='aichat -e'
alias cat='bat'
alias ls='eza --icons --git'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons'

# Delta: 1 arg -> git diff; 2 args -> diff two files
delta() {
  case $# in
    0) git diff ;;
    1) git diff -- "$1" ;;
    *) command delta "$@" ;;
  esac
}
