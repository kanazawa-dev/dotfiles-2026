#!/usr/bin/env bash
# ╭─────────────────────────────────────────────╮
# │     Kanazawa Dotfiles — Installer 2026      │
# ╰─────────────────────────────────────────────╯

set -e

# Colores
C_BLUE=$'\033[38;5;111m'
C_GREEN=$'\033[38;5;114m'
C_YELLOW=$'\033[38;5;221m'
C_RED=$'\033[38;5;210m'
C_DIM=$'\033[38;5;245m'
C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'

info()    { echo "  ${C_BLUE}→${C_RESET} $1"; }
success() { echo "  ${C_GREEN}✓${C_RESET} $1"; }
warn()    { echo "  ${C_YELLOW}!${C_RESET} $1"; }
error()   { echo "  ${C_RED}✗${C_RESET} $1"; exit 1; }
header()  { echo ""; echo "  ${C_BOLD}$1${C_RESET}"; echo "  ${C_DIM}$(printf '─%.0s' {1..45})${C_RESET}"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "  ${C_BLUE}${C_BOLD}╭─────────────────────────────────────────────╮${C_RESET}"
echo "  ${C_BLUE}${C_BOLD}│     Kanazawa Dotfiles — Installer 2026      │${C_RESET}"
echo "  ${C_BLUE}${C_BOLD}╰─────────────────────────────────────────────╯${C_RESET}"
echo ""

# ── 1. Homebrew ───────────────────────────────────────────────────────────
header "1. Homebrew"
if ! command -v brew &>/dev/null; then
  info "Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  success "Homebrew instalado"
else
  success "Homebrew ya está instalado"
fi

# ── 2. CLI Tools ──────────────────────────────────────────────────────────
header "2. CLI Tools"
BREWS=(
  neovim starship fzf ripgrep fd lazygit gh
  zsh-autosuggestions zsh-syntax-highlighting
  bat eza zoxide git-delta direnv pgcli node
)
for pkg in "${BREWS[@]}"; do
  if brew list "$pkg" &>/dev/null; then
    success "$pkg ya instalado"
  else
    info "Instalando $pkg..."
    brew install "$pkg" &>/dev/null && success "$pkg instalado"
  fi
done

# ── 3. Fuentes ────────────────────────────────────────────────────────────
header "3. Fuentes"
if brew list --cask font-monaspace &>/dev/null; then
  success "Monaspace ya instalada"
else
  info "Instalando Monaspace Neon..."
  brew install --cask font-monaspace &>/dev/null && success "Monaspace instalada"
fi

# ── 4. Configs ────────────────────────────────────────────────────────────
header "4. Configuraciones"

# Ghostty
mkdir -p ~/.config/ghostty
cp "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config
success "Ghostty config copiada"

# Neovim
mkdir -p ~/.config/nvim
cp -r "$DOTFILES_DIR/nvim/"* ~/.config/nvim/
success "Neovim config copiada"

# Starship
mkdir -p ~/.config
cp "$DOTFILES_DIR/starship/starship.toml" ~/.config/starship.toml
success "Starship config copiada"

# Zsh
cp "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
success ".zshrc copiado"

# Git
cp "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig
success ".gitconfig copiado"

# Claude Code
mkdir -p ~/.claude
cp "$DOTFILES_DIR/claude/statusline-command.sh" ~/.claude/statusline-command.sh
cp "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
chmod +x ~/.claude/statusline-command.sh
success "Claude Code status line configurada"

# hushlogin (quita el mensaje de Last login)
touch ~/.hushlogin
success ".hushlogin creado"

# ── 5. Neovim plugins ─────────────────────────────────────────────────────
header "5. Neovim — instalando plugins"
info "Esto puede tardar un momento..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null && success "Plugins de Neovim instalados"

# ── Listo ─────────────────────────────────────────────────────────────────
echo ""
echo "  ${C_GREEN}${C_BOLD}╭─────────────────────────────────────────────╮${C_RESET}"
echo "  ${C_GREEN}${C_BOLD}│   ✓ Setup completo. Abre una nueva tab.     │${C_RESET}"
echo "  ${C_GREEN}${C_BOLD}╰─────────────────────────────────────────────╯${C_RESET}"
echo ""
warn "Si usas Ghostty: instálalo desde https://ghostty.org"
warn "Reinicia el terminal para aplicar todos los cambios"
echo ""
