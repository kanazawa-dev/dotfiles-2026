# Kanazawa Dotfiles 2026

Setup completo de entorno de desarrollo para macOS. Una sola línea para instalarlo todo.

## Instalación rápida

```bash
git clone https://github.com/kanazawa-dev/dotfiles-2026.git ~/dotfiles-2026
cd ~/dotfiles-2026 && chmod +x install.sh && ./install.sh
```

---

## Qué incluye

### Ghostty — Terminal
Terminal moderno con GPU rendering nativo en macOS.

| Configuración | Valor |
|---|---|
| Tema claro | Catppuccin Latte |
| Tema oscuro | Catppuccin Mocha |
| Fuente | Monaspace Neon 13px |
| Cambio de tema | Automático con macOS |
| Transparencia | 92% con blur |

**Atajos configurados:**

| Atajo | Acción |
|---|---|
| `⌘ T` | Nueva tab |
| `⌘ W` | Cerrar panel |
| `⌘ K` | Limpiar pantalla |
| `⌘ D` | Split vertical → |
| `⌘ ⇧D` | Split horizontal ↓ |
| `⌘ ⇧↩` | Fullscreen |

---

### Zsh — Shell
Shell con plugins que cambian completamente la experiencia al escribir.

| Plugin | Función |
|---|---|
| `zsh-autosuggestions` | Sugiere comandos en gris basado en historial. Acepta con `→` |
| `zsh-syntax-highlighting` | Colorea comandos en tiempo real (verde = válido, rojo = no existe) |
| `fzf` | `Ctrl+R` para buscar historial visualmente. `Ctrl+T` para archivos |
| `starship` | Prompt minimalista con git, versión de lenguajes y duración de comandos |
| `zoxide` | Reemplaza `cd`. Aprende tus directorios y salta con `z nombre` |
| `direnv` | Carga `.env` automáticamente al entrar a un directorio |

**Aliases incluidos:**

| Comando | Qué hace |
|---|---|
| `cat` | → `bat` con syntax highlighting |
| `ls` | → `eza` con iconos y colores |
| `ll` | → `eza` lista detallada |
| `la` | → `eza` lista detallada con ocultos |
| `lt` | → `eza` árbol de directorios |
| `z <nombre>` | Salta al directorio más usado que matchea |
| `v` | Abre Neovim |
| `reload` | Recarga `.zshrc` |
| `mkcd <dir>` | Crea directorio y entra en un solo comando |
| `pgcli` | PostgreSQL con autocompletado inteligente |

**Git aliases:**

| Alias | Equivalente |
|---|---|
| `g s` | `git status -sb` |
| `g lg` | `git log --oneline --graph --decorate -20` |
| `g undo` | `git reset --soft HEAD~1` — deshace último commit sin perder cambios |
| `g oops` | `git commit --amend --no-edit` — agrega al último commit |
| `git diff` | → `delta` con side-by-side y líneas numeradas |

---

### Starship — Prompt
Prompt minimalista basado en el preset Tokyo Night.

Muestra en una sola línea:
- Directorio actual (últimos 3 niveles)
- Branch de git + estado (modificados, staged, etc.)
- Versión de Python/Node/Rust si hay archivo relevante en el directorio
- Tiempo del último comando si tardó más de 2 segundos

---

### Neovim — Editor
Config completa con LSP, autocompletado, fuzzy finder y git integrado.

**Atajos principales** (leader = `Space`):

| Atajo | Acción |
|---|---|
| `Space ?` | Ver **todos** los atajos disponibles |
| `Space e` | Explorador de archivos (Neo-tree) |
| `Space ff` | Buscar archivos en el proyecto |
| `Space fg` | Buscar texto en todo el proyecto |
| `Space fb` | Cambiar de buffer abierto |
| `Space fr` | Archivos abiertos recientemente |
| `Space gg` | LazyGit — interfaz visual de git |
| `Space t` | Terminal flotante |
| `Space w` | Guardar archivo |
| `Space lf` | Formatear archivo con LSP |
| `Space rn` | Renombrar símbolo |
| `Space ca` | Code actions |
| `gd` | Ir a definición |
| `gr` | Ver todas las referencias |
| `K` | Ver documentación del símbolo bajo cursor |
| `[d` / `]d` | Diagnóstico anterior / siguiente |
| `Shift+H` / `Shift+L` | Buffer anterior / siguiente |
| `Alt+J` / `Alt+K` | Mover línea arriba/abajo |
| `gcc` | Comentar/descomentar línea |
| `s` | Flash jump — salta a cualquier parte de la pantalla |

**LSP instalados automáticamente:**
- Python (`pyright`)
- TypeScript/JavaScript (`ts_ls`)
- Lua (`lua_ls`)
- Bash (`bashls`)
- JSON (`jsonls`)
- YAML (`yamlls`)

**Plugins incluidos:**
- **Catppuccin** — tema auto light/dark igual que Ghostty
- **Telescope** — fuzzy finder para archivos, texto, buffers
- **Neo-tree** — explorador lateral de archivos
- **nvim-cmp** — autocompletado con snippets
- **Treesitter** — syntax highlighting avanzado
- **Gitsigns** — cambios de git en el gutter
- **LazyGit** — git visual integrado en nvim
- **Which-key** — muestra atajos disponibles al presionar Space
- **Flash** — navegación ultrarrápida con `s`
- **ToggleTerm** — terminal integrada
- **Mason** — instala LSP servers automáticamente

---

### Claude Code — Status Line
Status line personalizada que muestra en tiempo real:

```
✦ Sonnet 4.6  ·  ▓▓░░░░░░░░ 18%  ·  ⚡ 4h 32m left  ·  󰔛 28m
```

| Elemento | Descripción |
|---|---|
| `✦ Sonnet 4.6` | Modelo activo |
| `▓▓░░░░░░░░ 18%` | Uso del contexto (verde < 50%, amarillo < 80%, rojo ≥ 80%) |
| `⚡ 4h 32m left` | Tiempo restante del reset de 5 horas (cambia de color según urgencia) |
| `󰔛 28m` | Duración de la sesión actual |

---

## Requisitos

- macOS 13+
- [Ghostty](https://ghostty.org) — instalar manualmente
- Nerd Font compatible (incluida: Monaspace)

## Estructura

```
dotfiles-2026/
├── install.sh          # Instalador automático
├── ghostty/config      # Config de Ghostty
├── nvim/               # Config completa de Neovim
├── zsh/.zshrc          # Zsh con plugins y aliases
├── starship/           # Prompt Tokyo Night
├── git/.gitconfig      # Git con delta y aliases
└── claude/             # Status line de Claude Code
```
