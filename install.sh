#!/usr/bin/env bash
# ╭─────────────────────────────────────────────╮
# │     Kanazawa Dotfiles — Installer 2026      │
# ╰─────────────────────────────────────────────╯

set -e

C_BLUE=$'\033[38;5;111m'
C_GREEN=$'\033[38;5;114m'
C_YELLOW=$'\033[38;5;221m'
C_RED=$'\033[38;5;210m'
C_MAUVE=$'\033[38;5;183m'
C_DIM=$'\033[38;5;245m'
C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'

info()    { echo "  ${C_BLUE}→${C_RESET}  $1"; }
success() { echo "  ${C_GREEN}✓${C_RESET}  $1"; }
warn()    { echo "  ${C_YELLOW}!${C_RESET}  $1"; }
skip()    { echo "  ${C_DIM}–${C_RESET}  ${C_DIM}$1 (omitido)${C_RESET}"; }
header()  { echo ""; echo "  ${C_BOLD}${C_BLUE}$1${C_RESET}"; echo "  ${C_DIM}$(printf '─%.0s' {1..45})${C_RESET}"; }

ask() {
  local msg="$1"
  echo ""
  printf "  ${C_MAUVE}?${C_RESET}  ${C_BOLD}%s${C_RESET} ${C_DIM}[s/n]${C_RESET} " "$msg"
  read -r resp
  [[ "$resp" =~ ^[sS]$ ]]
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Bienvenida ────────────────────────────────────────────────────────────
clear
echo ""
echo "  ${C_BLUE}${C_BOLD}╭─────────────────────────────────────────────╮${C_RESET}"
echo "  ${C_BLUE}${C_BOLD}│     Kanazawa Dotfiles — Installer 2026      │${C_RESET}"
echo "  ${C_BLUE}${C_BOLD}╰─────────────────────────────────────────────╯${C_RESET}"
echo ""
echo "  Este script instala y configura tu entorno de desarrollo."
echo "  Puedes elegir qué instalar en cada paso."
echo ""
echo "  ${C_DIM}Presiona Enter para continuar...${C_RESET}"
read -r

# ── 1. Homebrew ───────────────────────────────────────────────────────────
header "1/7  Homebrew — gestor de paquetes de macOS"
echo ""
echo "  Homebrew instala todas las herramientas que usaremos."
echo "  Es imprescindible para el resto de la instalación."
echo ""
if ! command -v brew &>/dev/null; then
  if ask "¿Instalar Homebrew?"; then
    info "Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    success "Homebrew instalado"
  else
    echo ""
    warn "Sin Homebrew no se puede continuar. Saliendo."
    exit 1
  fi
else
  success "Homebrew ya instalado"
fi

# ── 2. Ghostty ────────────────────────────────────────────────────────────
header "2/7  Ghostty — terminal"
echo ""
echo "  Terminal moderno con GPU rendering, transparencia y blur."
echo "  Soporta cambio automático de tema con macOS (claro/oscuro)."
echo "  Usa Catppuccin Latte en modo claro y Catppuccin Mocha en oscuro."
echo ""
if ask "¿Instalar config de Ghostty?"; then
  mkdir -p ~/.config/ghostty
  cp "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config
  success "Config de Ghostty copiada (~/.config/ghostty/config)"
  warn "Si no tienes Ghostty: descárgalo en https://ghostty.org"

  if ask "¿Instalar fuente Monaspace Neon?"; then
    info "Instalando Monaspace..."
    brew install --cask font-monaspace &>/dev/null
    success "Monaspace instalada"
  fi
else
  skip "Ghostty"
fi

# ── 3. Zsh ────────────────────────────────────────────────────────────────
header "3/7  Zsh — shell con plugins"
echo ""
echo "  Incluye:"
echo "  ${C_GREEN}•${C_RESET} zsh-autosuggestions  — sugiere comandos en gris (acepta con →)"
echo "  ${C_GREEN}•${C_RESET} zsh-syntax-highlighting — colorea comandos en tiempo real"
echo "  ${C_GREEN}•${C_RESET} fzf                  — búsqueda visual del historial (Ctrl+R)"
echo "  ${C_GREEN}•${C_RESET} zoxide               — reemplaza cd, aprende tus directorios"
echo "  ${C_GREEN}•${C_RESET} direnv               — carga .env automáticamente por directorio"
echo "  ${C_GREEN}•${C_RESET} bat                  — cat con syntax highlighting"
echo "  ${C_GREEN}•${C_RESET} eza                  — ls con iconos y colores"
echo "  ${C_GREEN}•${C_RESET} git-delta            — diffs de git side-by-side"
echo ""
if ask "¿Instalar plugins y config de Zsh?"; then
  info "Instalando paquetes..."
  brew install zsh-autosuggestions zsh-syntax-highlighting fzf zoxide \
               direnv bat eza git-delta pgcli &>/dev/null
  success "Paquetes instalados"
  cp "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
  success ".zshrc copiado (~/.zshrc)"
  touch ~/.hushlogin
  success "Mensaje 'Last login' desactivado"
else
  skip "Zsh"
fi

# ── 4. Starship ───────────────────────────────────────────────────────────
header "4/7  Starship — prompt"
echo ""
echo "  Prompt minimalista en una sola línea que muestra:"
echo "  ${C_GREEN}•${C_RESET} Directorio actual"
echo "  ${C_GREEN}•${C_RESET} Branch de git y estado (modificados, staged, etc.)"
echo "  ${C_GREEN}•${C_RESET} Versión de Python/Node/Rust si estás en ese proyecto"
echo "  ${C_GREEN}•${C_RESET} Tiempo del último comando si tardó más de 2 segundos"
echo ""
if ask "¿Instalar Starship y su config?"; then
  brew install starship &>/dev/null
  mkdir -p ~/.config
  cp "$DOTFILES_DIR/starship/starship.toml" ~/.config/starship.toml
  success "Starship instalado y configurado"
else
  skip "Starship"
fi

# ── 5. Git ────────────────────────────────────────────────────────────────
header "5/7  Git — config y aliases"
echo ""
echo "  Incluye:"
echo "  ${C_GREEN}•${C_RESET} delta        — diffs side-by-side con syntax highlighting"
echo "  ${C_GREEN}•${C_RESET} git s        — status resumido"
echo "  ${C_GREEN}•${C_RESET} git lg       — log visual con grafo"
echo "  ${C_GREEN}•${C_RESET} git undo     — deshace último commit sin perder cambios"
echo "  ${C_GREEN}•${C_RESET} git oops     — agrega al último commit sin cambiar mensaje"
echo "  ${C_GREEN}•${C_RESET} nvim como editor por defecto"
echo ""
warn "IMPORTANTE: esto sobreescribirá tu .gitconfig actual."
if ask "¿Instalar .gitconfig?"; then
  cp "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig
  success ".gitconfig copiado"
  warn "Recuerda actualizar tu nombre y email en ~/.gitconfig"
else
  skip "Git config"
fi

# ── 6. Neovim ─────────────────────────────────────────────────────────────
header "6/7  Neovim — editor"
echo ""
echo "  Config completa con:"
echo "  ${C_GREEN}•${C_RESET} Catppuccin — tema auto light/dark (igual que Ghostty)"
echo "  ${C_GREEN}•${C_RESET} LSP        — Python, TypeScript, Lua, Bash, JSON, YAML"
echo "  ${C_GREEN}•${C_RESET} Telescope  — fuzzy finder para archivos y texto"
echo "  ${C_GREEN}•${C_RESET} LazyGit    — git visual integrado"
echo "  ${C_GREEN}•${C_RESET} Which-key  — muestra atajos al presionar Space"
echo "  ${C_GREEN}•${C_RESET} Flash      — navegación ultrarrápida con 's'"
echo "  ${C_GREEN}•${C_RESET} nvim-cmp   — autocompletado con snippets"
echo ""
echo "  Atajos principales (leader = Space):"
echo "  ${C_DIM}Space+e${C_RESET}  explorador  ${C_DIM}Space+ff${C_RESET}  buscar archivos"
echo "  ${C_DIM}Space+fg${C_RESET} buscar texto ${C_DIM}Space+gg${C_RESET} LazyGit"
echo "  ${C_DIM}Space+t${C_RESET}  terminal    ${C_DIM}Space+?${C_RESET}  ver todos los atajos"
echo ""
if ask "¿Instalar Neovim y su config?"; then
  brew install neovim lazygit ripgrep fd node &>/dev/null
  mkdir -p ~/.config/nvim
  cp -r "$DOTFILES_DIR/nvim/"* ~/.config/nvim/
  success "Neovim config copiada"
  info "Instalando plugins (puede tardar un momento)..."
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  success "Plugins instalados"
else
  skip "Neovim"
fi

# ── 7. Claude Code ────────────────────────────────────────────────────────
header "7/7  Claude Code — status line"
echo ""
echo "  Status line personalizada que muestra:"
echo "  ${C_GREEN}✦${C_RESET} Modelo activo"
echo "  ${C_GREEN}▓▓░░░░░░░░${C_RESET} Uso del contexto con barra visual"
echo "  ${C_GREEN}⚡${C_RESET} Tiempo restante del reset de 5 horas"
echo "  ${C_GREEN}󰔛${C_RESET} Duración de la sesión actual"
echo ""
if ask "¿Instalar status line de Claude Code?"; then
  mkdir -p ~/.claude
  cp "$DOTFILES_DIR/claude/statusline-command.sh" ~/.claude/statusline-command.sh
  cp "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
  chmod +x ~/.claude/statusline-command.sh
  success "Claude Code status line instalada"
else
  skip "Claude Code"
fi

# ── Fin ───────────────────────────────────────────────────────────────────
echo ""
echo "  ${C_GREEN}${C_BOLD}╭─────────────────────────────────────────────╮${C_RESET}"
echo "  ${C_GREEN}${C_BOLD}│          ✓ Instalación completa             │${C_RESET}"
echo "  ${C_GREEN}${C_BOLD}╰─────────────────────────────────────────────╯${C_RESET}"
echo ""
echo "  ${C_BOLD}Próximos pasos:${C_RESET}"
echo "  ${C_DIM}1.${C_RESET} Abre una nueva tab del terminal"
echo "  ${C_DIM}2.${C_RESET} Si instalaste .gitconfig: edita nombre/email con ${C_BLUE}nvim ~/.gitconfig${C_RESET}"
echo "  ${C_DIM}3.${C_RESET} Para direnv: crea un ${C_BLUE}.envrc${C_RESET} en tu proyecto y ejecuta ${C_BLUE}direnv allow${C_RESET}"
echo "  ${C_DIM}4.${C_RESET} En nvim presiona ${C_BLUE}Space ?${C_RESET} para ver todos los atajos"
echo ""
