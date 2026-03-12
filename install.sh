#!/usr/bin/env bash
# Kanazawa Dotfiles 2026 — Interactive Wizard

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colores
B=$'\033[38;5;111m'   # blue
G=$'\033[38;5;114m'   # green
Y=$'\033[38;5;221m'   # yellow
R=$'\033[38;5;210m'   # red
M=$'\033[38;5;183m'   # mauve
D=$'\033[38;5;245m'   # dim
W=$'\033[0m'          # reset
BOLD=$'\033[1m'

# Decisiones del usuario
DO_GHOSTTY=false
DO_FONT=false
DO_ZSH=false
DO_STARSHIP=false
DO_GIT=false
DO_NVIM=false
DO_CLAUDE=false

# ── Helpers ───────────────────────────────────────────────────────────────
cls() { printf '\033[2J\033[H'; }

print_header() {
  local step="$1" total="$2" title="$3"
  echo ""
  echo "  ${B}${BOLD}Kanazawa Dotfiles 2026${W}  ${D}paso ${step}/${total}${W}"
  echo "  ${D}$(printf '─%.0s' {1..50})${W}"
  echo ""
  echo "  ${BOLD}${title}${W}"
  echo ""
}

print_progress() {
  local current="$1" total="$2"
  local filled=$(( current * 20 / total ))
  local empty=$(( 20 - filled ))
  local bar=""
  for _ in $(seq 1 $filled); do bar="${bar}${G}▓${W}"; done
  for _ in $(seq 1 $empty);  do bar="${bar}${D}░${W}"; done
  echo "  ${bar}  ${D}${current}/${total}${W}"
}

ask() {
  local question="$1"
  echo ""
  printf "  ${M}?${W}  ${question} ${D}[s/n]${W}  "
  read -r resp
  [[ "$resp" =~ ^[sS]$ ]]
}

press_enter() {
  echo ""
  printf "  ${D}↵  Presiona Enter para continuar...${W}"
  read -r
}

run_step() {
  local msg="$1"; shift
  printf "  ${B}→${W}  ${msg}..."
  if "$@" &>/dev/null 2>&1; then
    printf "\r  ${G}✓${W}  ${msg}         \n"
  else
    printf "\r  ${R}✗${W}  ${msg} (error) \n"
  fi
}

# ══════════════════════════════════════════════════════════════════════════
# BIENVENIDA
# ══════════════════════════════════════════════════════════════════════════
cls
echo ""
echo "  ${B}${BOLD}╭──────────────────────────────────────────────────╮${W}"
echo "  ${B}${BOLD}│                                                  │${W}"
echo "  ${B}${BOLD}│       Kanazawa Dotfiles — Wizard 2026            │${W}"
echo "  ${B}${BOLD}│                                                  │${W}"
echo "  ${B}${BOLD}╰──────────────────────────────────────────────────╯${W}"
echo ""
echo "  Este wizard configura tu entorno de desarrollo paso a paso."
echo "  Puedes elegir exactamente qué instalar."
echo ""
echo "  ${D}Incluye: Ghostty · Zsh · Starship · Git · Neovim · Claude${W}"
echo ""
press_enter

# ══════════════════════════════════════════════════════════════════════════
# PASO 1 — HOMEBREW
# ══════════════════════════════════════════════════════════════════════════
cls
print_header 1 7 "Homebrew — gestor de paquetes"
print_progress 1 7
echo ""
echo "  Homebrew es el gestor de paquetes de macOS."
echo "  Todo lo que instalamos depende de él."
echo ""
if command -v brew &>/dev/null; then
  echo "  ${G}✓${W}  Ya instalado en $(brew --prefix)"
else
  echo "  ${R}✗${W}  No encontrado"
  if ask "¿Instalar Homebrew?"; then
    echo ""
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo ""
    echo "  ${R}Sin Homebrew no se puede continuar.${W}"
    exit 1
  fi
fi
press_enter

# ══════════════════════════════════════════════════════════════════════════
# PASO 2 — GHOSTTY
# ══════════════════════════════════════════════════════════════════════════
cls
print_header 2 7 "Ghostty — terminal"
print_progress 2 7
echo ""
echo "  ${BOLD}Vista previa de la config:${W}"
echo ""
echo "  ${D}┌──────────────────────────────────────────┐${W}"
echo "  ${D}│${W}  tema claro   ${G}Catppuccin Latte${W}           ${D}│${W}"
echo "  ${D}│${W}  tema oscuro  ${M}Catppuccin Mocha${W}           ${D}│${W}"
echo "  ${D}│${W}  fuente       ${B}Monaspace Neon 13px${W}        ${D}│${W}"
echo "  ${D}│${W}  transparencia ${Y}92%${W} con blur macOS       ${D}│${W}"
echo "  ${D}│${W}  cambio tema  automático con macOS      ${D}│${W}"
echo "  ${D}└──────────────────────────────────────────┘${W}"
echo ""
echo "  ${BOLD}Atajos configurados:${W}"
echo ""
echo "  ${B}⌘ T${W}  nueva tab     ${B}⌘ D${W}   split →"
echo "  ${B}⌘ W${W}  cerrar        ${B}⌘ ⇧D${W}  split ↓"
echo "  ${B}⌘ K${W}  limpiar       ${B}⌘ ⇧↩${W}  fullscreen"
echo ""
if ask "¿Instalar config de Ghostty?"; then
  DO_GHOSTTY=true
  if ask "¿Instalar fuente Monaspace Neon?"; then
    DO_FONT=true
  fi
fi
press_enter

# ══════════════════════════════════════════════════════════════════════════
# PASO 3 — ZSH
# ══════════════════════════════════════════════════════════════════════════
cls
print_header 3 7 "Zsh — shell con plugins y aliases"
print_progress 3 7
echo ""
echo "  ${BOLD}Plugins:${W}"
echo ""
echo "  ${G}zsh-autosuggestions${W}    sugiere comandos en gris mientras escribes"
echo "                         acepta con ${B}→${W}"
echo ""
echo "  ${G}zsh-syntax-highlighting${W} colorea comandos en tiempo real"
echo "                         ${G}verde${W} = válido  ${R}rojo${W} = no existe"
echo ""
echo "  ${G}fzf${W}                    búsqueda visual del historial"
echo "                         ${B}Ctrl+R${W} historial  ${B}Ctrl+T${W} archivos"
echo ""
echo "  ${G}zoxide${W}                 reemplaza cd, aprende tus paths"
echo "                         ${B}z pro${W} → salta al dir que más usas con 'pro'"
echo ""
echo "  ${G}direnv${W}                 carga ${B}.env${W} automáticamente al entrar al dir"
echo ""
echo "  ${BOLD}Aliases:${W}"
echo ""
echo "  ${B}cat${W} → bat (syntax)   ${B}ls${W} → eza (iconos)   ${B}ll${W} → eza detallado"
echo "  ${B}v${W}   → nvim           ${B}mkcd${W} → crea y entra   ${B}reload${W} → recarga zsh"
echo ""
if ask "¿Instalar plugins y config de Zsh?"; then
  DO_ZSH=true
fi
press_enter

# ══════════════════════════════════════════════════════════════════════════
# PASO 4 — STARSHIP
# ══════════════════════════════════════════════════════════════════════════
cls
print_header 4 7 "Starship — prompt"
print_progress 4 7
echo ""
echo "  Prompt minimalista en una sola línea."
echo "  Preset: ${B}Tokyo Night${W}"
echo ""
echo "  ${BOLD}Vista previa:${W}"
echo ""
echo "  ${D}~/workspace/mi-proyecto${W} ${M}main${W} ${R}✗${W}"
echo "  ${G}❯${W} "
echo ""
echo "  ${BOLD}Muestra:${W}"
echo ""
echo "  ${G}•${W} Directorio actual"
echo "  ${G}•${W} Branch de git + cambios pendientes"
echo "  ${G}•${W} Versión de Python/Node/Rust si aplica"
echo "  ${G}•${W} Tiempo del último comando si tardó más de ${Y}2 segundos${W}"
echo ""
if ask "¿Instalar Starship?"; then
  DO_STARSHIP=true
fi
press_enter

# ══════════════════════════════════════════════════════════════════════════
# PASO 5 — GIT
# ══════════════════════════════════════════════════════════════════════════
cls
print_header 5 7 "Git — config y aliases"
print_progress 5 7
echo ""
echo "  ${BOLD}delta${W} — diffs side-by-side con syntax highlighting"
echo ""
echo "  ${D}┌──── antes ──────────┬──── después ─────────┐${W}"
echo "  ${D}│${R} - const x = 1      ${D}│${G} + const x = 2       ${D}│${W}"
echo "  ${D}└─────────────────────┴──────────────────────┘${W}"
echo ""
echo "  ${BOLD}Aliases:${W}"
echo ""
echo "  ${B}git s${W}     → status resumido"
echo "  ${B}git lg${W}    → log visual con grafo"
echo "  ${B}git undo${W}  → deshace último commit ${D}(sin perder cambios)${W}"
echo "  ${B}git oops${W}  → agrega al último commit ${D}(sin cambiar mensaje)${W}"
echo ""
echo "  ${Y}!${W}  Esto sobreescribirá tu .gitconfig actual"
echo "  ${D}   Recuerda actualizar tu nombre y email después${W}"
echo ""
if ask "¿Instalar .gitconfig?"; then
  DO_GIT=true
fi
press_enter

# ══════════════════════════════════════════════════════════════════════════
# PASO 6 — NEOVIM
# ══════════════════════════════════════════════════════════════════════════
cls
print_header 6 7 "Neovim — editor"
print_progress 6 7
echo ""
echo "  ${BOLD}Plugins incluidos:${W}"
echo ""
echo "  ${G}Catppuccin${W}   tema auto light/dark igual que Ghostty"
echo "  ${G}LSP${W}          Python · TypeScript · Lua · Bash · JSON · YAML"
echo "  ${G}nvim-cmp${W}     autocompletado con snippets"
echo "  ${G}Telescope${W}    fuzzy finder para archivos y texto"
echo "  ${G}Neo-tree${W}     explorador lateral de archivos"
echo "  ${G}LazyGit${W}      git visual integrado"
echo "  ${G}Which-key${W}    muestra atajos al presionar Space"
echo "  ${G}Flash${W}        salta a cualquier parte con ${B}s${W}"
echo "  ${G}Treesitter${W}   syntax highlighting avanzado"
echo ""
echo "  ${BOLD}Atajos principales${W} ${D}(leader = Space):${W}"
echo ""
echo "  ${B}Space e${W}   explorador    ${B}Space ff${W}  buscar archivos"
echo "  ${B}Space fg${W}  buscar texto  ${B}Space gg${W}  LazyGit"
echo "  ${B}Space t${W}   terminal      ${B}Space ?${W}   todos los atajos"
echo "  ${B}gd${W}        definición    ${B}K${W}         documentación"
echo ""
if ask "¿Instalar Neovim?"; then
  DO_NVIM=true
fi
press_enter

# ══════════════════════════════════════════════════════════════════════════
# PASO 7 — CLAUDE CODE
# ══════════════════════════════════════════════════════════════════════════
cls
print_header 7 7 "Claude Code — status line"
print_progress 7 7
echo ""
echo "  Status line personalizada para Claude Code."
echo ""
echo "  ${BOLD}Vista previa:${W}"
echo ""
echo "  ${D}✦${W} ${B}${BOLD}Sonnet 4.6${W}  ${D}·${W}  ${G}▓▓░░░░░░░░ 18%${W}  ${D}·${W}  ${G}⚡ 4h 32m left${W}  ${D}·${W}  ${M}󰔛 28m${W}"
echo ""
echo "  ${D}────────────────────────────────────────────${W}"
echo ""
echo "  ${B}✦ Sonnet 4.6${W}    modelo activo"
echo "  ${G}▓▓░░░░░░░░ 18%${W} uso del contexto ${D}(verde/amarillo/rojo)${W}"
echo "  ${G}⚡ 4h 32m left${W}  tiempo restante del reset de 5 horas"
echo "  ${M}󰔛 28m${W}          duración de la sesión actual"
echo ""
if ask "¿Instalar status line de Claude Code?"; then
  DO_CLAUDE=true
fi
press_enter

# ══════════════════════════════════════════════════════════════════════════
# RESUMEN
# ══════════════════════════════════════════════════════════════════════════
cls
echo ""
echo "  ${B}${BOLD}╭──────────────────────────────────────────────────╮${W}"
echo "  ${B}${BOLD}│              Resumen de instalación              │${W}"
echo "  ${B}${BOLD}╰──────────────────────────────────────────────────╯${W}"
echo ""

check() { $1 && echo "  ${G}✓${W}  $2" || echo "  ${D}–  $2 (omitido)${W}"; }
check $DO_GHOSTTY  "Ghostty config"
check $DO_FONT     "Monaspace Neon"
check $DO_ZSH      "Zsh plugins y aliases"
check $DO_STARSHIP "Starship prompt"
check $DO_GIT      "Git config y aliases"
check $DO_NVIM     "Neovim"
check $DO_CLAUDE   "Claude Code status line"

echo ""
if ask "¿Confirmar e instalar?"; then
  echo ""
else
  echo ""
  echo "  Instalación cancelada."
  exit 0
fi

# ══════════════════════════════════════════════════════════════════════════
# INSTALACIÓN
# ══════════════════════════════════════════════════════════════════════════
cls
echo ""
echo "  ${B}${BOLD}Instalando...${W}"
echo ""

if $DO_GHOSTTY; then
  mkdir -p ~/.config/ghostty
  run_step "Copiando config de Ghostty" cp "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config
fi

if $DO_FONT; then
  run_step "Instalando Monaspace Neon" brew install --cask font-monaspace
fi

if $DO_ZSH; then
  run_step "Instalando plugins de Zsh" brew install zsh-autosuggestions zsh-syntax-highlighting fzf zoxide direnv bat eza git-delta pgcli
  run_step "Copiando .zshrc" cp "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
  touch ~/.hushlogin
  echo "  ${G}✓${W}  Mensaje 'Last login' desactivado"
fi

if $DO_STARSHIP; then
  run_step "Instalando Starship" brew install starship
  mkdir -p ~/.config
  run_step "Copiando starship.toml" cp "$DOTFILES_DIR/starship/starship.toml" ~/.config/starship.toml
fi

if $DO_GIT; then
  run_step "Copiando .gitconfig" cp "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig
fi

if $DO_NVIM; then
  run_step "Instalando Neovim" brew install neovim lazygit ripgrep fd node
  mkdir -p ~/.config/nvim
  run_step "Copiando config de Neovim" cp -r "$DOTFILES_DIR/nvim/"* ~/.config/nvim/
  run_step "Instalando plugins (lazy.nvim)" nvim --headless "+Lazy! sync" +qa
fi

if $DO_CLAUDE; then
  mkdir -p ~/.claude
  run_step "Copiando status line" cp "$DOTFILES_DIR/claude/statusline-command.sh" ~/.claude/statusline-command.sh
  run_step "Copiando settings" cp "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
  chmod +x ~/.claude/statusline-command.sh
fi

# ── Fin ───────────────────────────────────────────────────────────────────
echo ""
echo "  ${G}${BOLD}╭──────────────────────────────────────────────────╮${W}"
echo "  ${G}${BOLD}│              ✓  Setup completo                   │${W}"
echo "  ${G}${BOLD}╰──────────────────────────────────────────────────╯${W}"
echo ""
echo "  ${BOLD}Próximos pasos:${W}"
echo ""
echo "  ${D}1.${W}  Abre una nueva tab"
$DO_GIT      && echo "  ${D}2.${W}  Actualiza nombre y email: ${B}nvim ~/.gitconfig${W}"
$DO_NVIM     && echo "  ${D}3.${W}  En nvim presiona ${B}Space ?${W} para ver todos los atajos"
$DO_ZSH      && echo "  ${D}4.${W}  En tu proyecto: crea ${B}.envrc${W} y ejecuta ${B}direnv allow${W}"
echo ""
