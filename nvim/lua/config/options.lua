local opt = vim.opt

-- UI
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.wrap           = false
opt.termguicolors  = true
opt.showmode       = false        -- lualine lo muestra
opt.cmdheight      = 1
opt.pumheight      = 10
opt.laststatus     = 3            -- statusline global

-- Tabs / indentación
opt.expandtab      = true
opt.shiftwidth     = 2
opt.tabstop        = 2
opt.smartindent    = true

-- Búsqueda
opt.ignorecase     = true
opt.smartcase      = true
opt.hlsearch       = true
opt.incsearch      = true

-- Splits
opt.splitbelow     = true
opt.splitright     = true

-- Archivos
opt.undofile       = true
opt.swapfile       = false
opt.backup         = false
opt.updatetime     = 200
opt.timeoutlen     = 300
opt.clipboard      = "unnamedplus"   -- sync con clipboard de macOS

-- Apariencia
opt.conceallevel   = 0
opt.fillchars      = { eob = " " }  -- sin ~ al final del buffer
opt.list           = true
opt.listchars      = { tab = "→ ", trail = "·" }
