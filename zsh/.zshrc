
. "$HOME/.local/bin/env"

# Atajos Ghostty
echo ""
echo "  \033[38;5;110m╭─────────────────────────────────────────╮\033[0m"
echo "  \033[38;5;110m│\033[0m           \033[1;38;5;75m Kanazawa  Shortcuts\033[0m            \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m├─────────────────────┬───────────────────┤\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75m⌘ T\033[0m   nueva tab     \033[38;5;110m│\033[0m  \033[1;38;5;75m⌘ D\033[0m   split →   \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75m⌘ W\033[0m   cerrar panel  \033[38;5;110m│\033[0m  \033[1;38;5;75m⌘ ⇧D\033[0m  split ↓   \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75m⌘ K\033[0m   limpiar       \033[38;5;110m│\033[0m  \033[1;38;5;75m⌘ ⇧↩\033[0m  fullscreen \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m╰─────────────────────┴───────────────────╯\033[0m"
echo ""
echo "  \033[38;5;110m╭──────────────┬─────────────────────────────────────────────────╮\033[0m"
echo "  \033[38;5;110m│\033[0m   \033[1;38;5;75mComando\033[0m      \033[38;5;110m│\033[0m                  \033[1;38;5;75mAlias / Mejora\033[0m                  \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m├──────────────┼─────────────────────────────────────────────────┤\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mcat\033[0m          \033[38;5;110m│\033[0m  bat — syntax highlighting                      \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mls\033[0m           \033[38;5;110m│\033[0m  eza — iconos y colores                          \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mll\033[0m           \033[38;5;110m│\033[0m  eza lista detallada                             \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mlt\033[0m           \033[38;5;110m│\033[0m  eza árbol de directorios                        \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mz <nombre>\033[0m   \033[38;5;110m│\033[0m  zoxide — salta al dir más usado que matchea     \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mgit diff\033[0m     \033[38;5;110m│\033[0m  delta — side-by-side con líneas numeradas       \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mgit lg\033[0m       \033[38;5;110m│\033[0m  log visual con grafo                            \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mgit undo\033[0m     \033[38;5;110m│\033[0m  deshace el último commit sin perder cambios     \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mgit oops\033[0m     \033[38;5;110m│\033[0m  agrega al último commit sin cambiar mensaje     \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mv\033[0m            \033[38;5;110m│\033[0m  abre nvim                                       \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mreload\033[0m       \033[38;5;110m│\033[0m  recarga .zshrc                                  \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mmkcd\033[0m         \033[38;5;110m│\033[0m  crea directorio y entra en uno solo comando     \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mpgcli\033[0m        \033[38;5;110m│\033[0m  PostgreSQL con autocompletado inteligente        \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m│\033[0m  \033[1;38;5;75mdirenv\033[0m       \033[38;5;110m│\033[0m  carga .env al entrar al directorio              \033[38;5;110m│\033[0m"
echo "  \033[38;5;110m╰──────────────┴─────────────────────────────────────────────────╯\033[0m"
echo ""

# Plugins
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval "$(fzf --zsh)"

# Starship prompt
eval "$(starship init zsh)"

# Zoxide (reemplaza cd)
eval "$(zoxide init zsh)"

# Direnv (carga .env automáticamente por directorio)
eval "$(direnv hook zsh)"

# mkcd — crea directorio y entra
mkcd() { mkdir -p "$1" && cd "$1" }

# ── Historial ────────────────────────────────────────────────────────────
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt HIST_VERIFY

# ── Aliases — CLI tools mejorados ────────────────────────────────────────
alias cat="bat --style=plain"
alias ls="eza --icons --group-directories-first"
alias ll="eza --icons --group-directories-first -l"
alias la="eza --icons --group-directories-first -la"
alias lt="eza --icons --tree --level=2"
alias cd="z"

# ── Aliases — Git ─────────────────────────────────────────────────────────
alias g="git"
alias gs="git status -sb"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"
alias glg="git log --oneline --graph --decorate -20"

# ── Aliases — Dev ─────────────────────────────────────────────────────────
alias v="nvim"
alias ..="cd .."
alias ...="cd ../.."
alias reload="source ~/.zshrc"
