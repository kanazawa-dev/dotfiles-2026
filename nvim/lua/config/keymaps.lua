local map = vim.keymap.set

vim.g.mapleader      = " "    -- Space como leader
vim.g.maplocalleader = " "

-- ── Básicos ────────────────────────────────────────────────────────────────
map("n", "<Esc>",       "<cmd>nohlsearch<CR>")          -- limpiar búsqueda
map("n", "<leader>w",   "<cmd>w<CR>",        { desc = "Guardar" })
map("n", "<leader>q",   "<cmd>q<CR>",        { desc = "Cerrar" })
map("n", "<leader>Q",   "<cmd>qa!<CR>",      { desc = "Salir todo" })

-- ── Navegación entre ventanas ─────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Ventana ←" })
map("n", "<C-j>", "<C-w>j", { desc = "Ventana ↓" })
map("n", "<C-k>", "<C-w>k", { desc = "Ventana ↑" })
map("n", "<C-l>", "<C-w>l", { desc = "Ventana →" })

-- ── Redimensionar splits ──────────────────────────────────────────────────
map("n", "<C-Up>",    "<cmd>resize +2<CR>")
map("n", "<C-Down>",  "<cmd>resize -2<CR>")
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- ── Buffers ───────────────────────────────────────────────────────────────
map("n", "<S-h>",       "<cmd>bprevious<CR>",  { desc = "Buffer anterior" })
map("n", "<S-l>",       "<cmd>bnext<CR>",      { desc = "Buffer siguiente" })
map("n", "<leader>bd",  "<cmd>bdelete<CR>",    { desc = "Cerrar buffer" })

-- ── Mover líneas ─────────────────────────────────────────────────────────
map("n", "<A-j>", "<cmd>m .+1<CR>==",           { desc = "Mover línea ↓" })
map("n", "<A-k>", "<cmd>m .-2<CR>==",           { desc = "Mover línea ↑" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv",          { desc = "Mover selección ↓" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv",          { desc = "Mover selección ↑" })

-- ── Indentación en visual mode ────────────────────────────────────────────
map("v", "<", "<gv")
map("v", ">", ">gv")

-- ── File explorer ─────────────────────────────────────────────────────────
map("n", "<leader>e",  "<cmd>Neotree toggle<CR>",  { desc = "Explorador" })

-- ── Telescope ─────────────────────────────────────────────────────────────
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>",   { desc = "Buscar archivos" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",    { desc = "Buscar texto" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",      { desc = "Buffers" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>",     { desc = "Archivos recientes" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>",      { desc = "Keymaps" })
map("n", "<leader>fc", "<cmd>Telescope commands<CR>",     { desc = "Comandos" })

-- ── LSP (se sobreescriben al adjuntar LSP) ────────────────────────────────
map("n", "gd",         vim.lsp.buf.definition,      { desc = "Ir a definición" })
map("n", "gr",         vim.lsp.buf.references,      { desc = "Referencias" })
map("n", "K",          vim.lsp.buf.hover,           { desc = "Hover docs" })
map("n", "<leader>rn", vim.lsp.buf.rename,          { desc = "Renombrar" })
map("n", "<leader>ca", vim.lsp.buf.code_action,     { desc = "Code action" })
map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Formatear" })
map("n", "[d",         vim.diagnostic.goto_prev,    { desc = "Diagnóstico anterior" })
map("n", "]d",         vim.diagnostic.goto_next,    { desc = "Diagnóstico siguiente" })

-- ── Terminal ──────────────────────────────────────────────────────────────
map("n", "<leader>t",  "<cmd>ToggleTerm<CR>",       { desc = "Terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>",               { desc = "Salir terminal" })

-- ── Git ───────────────────────────────────────────────────────────────────
map("n", "<leader>gg", "<cmd>LazyGit<CR>",          { desc = "LazyGit" })

-- ── Which-key (ver todos los atajos) ─────────────────────────────────────
map("n", "<leader>?",  "<cmd>WhichKey<CR>",         { desc = "Ver todos los atajos" })
