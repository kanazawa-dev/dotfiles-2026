# dotfiles 2026

My personal dev environment configuration.

## What's inside

| Tool | Config |
|---|---|
| **Ghostty** | Theme auto light/dark (Catppuccin), Monaspace Neon font, custom keybindings |
| **Neovim** | Catppuccin, LSP, Telescope, LazyGit, Treesitter, nvim-cmp |
| **Zsh** | zsh-autosuggestions, zsh-syntax-highlighting, fzf, Starship prompt |
| **Starship** | Tokyo Night preset, single-line prompt |
| **Claude Code** | Custom status line with context bar, 5h reset countdown, session timer |

## Install

```bash
# Ghostty
cp ghostty/config ~/.config/ghostty/config

# Neovim
cp -r nvim ~/.config/nvim

# Zsh
cp zsh/.zshrc ~/.zshrc

# Starship
cp starship/starship.toml ~/.config/starship.toml

# Claude Code status line
cp claude/statusline-command.sh ~/.claude/
cp claude/settings.json ~/.claude/
```

## Dependencies

```bash
brew install neovim starship fzf zsh-autosuggestions zsh-syntax-highlighting ripgrep fd lazygit gh
brew install --cask font-monaspace ghostty
```
