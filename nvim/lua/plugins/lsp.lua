return {
  -- ── Mason (instala LSPs automáticamente) ──────────────────────────────
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts  = { ui = { border = "rounded" } },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "pyright", "ts_ls", "lua_ls", "bashls", "jsonls", "yamlls" },
      automatic_installation = true,
    },
  },

  -- ── nvim-lspconfig ────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      -- Nueva API (nvim 0.11+)
      vim.lsp.config("pyright",  {})
      vim.lsp.config("ts_ls",    {})
      vim.lsp.config("bashls",   {})
      vim.lsp.config("jsonls",   {})
      vim.lsp.config("yamlls",   {})
      vim.lsp.config("lua_ls",   {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      vim.lsp.enable({ "pyright", "ts_ls", "bashls", "jsonls", "yamlls", "lua_ls" })

      -- Diagnósticos con iconos bonitos
      vim.diagnostic.config({
        virtual_text  = { prefix = "●" },
        severity_sort = true,
        float         = { border = "rounded" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = "󰠠 ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
      })
    end,
  },

  -- ── Autocompletado ─────────────────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    event        = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-j>"]   = cmp.mapping.select_next_item(),
          ["<C-k>"]   = cmp.mapping.select_prev_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]   = cmp.mapping.abort(),
          ["<CR>"]    = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]   = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(_, item)
            local icons = {
              Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "",
              Field = "󰜢", Variable = "󰀫", Class = "󰠱", Interface = "",
              Module = "", Property = "󰜢", Unit = "󰑭", Value = "󰎠",
              Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
              File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
              Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕",
              TypeParameter = "",
            }
            item.kind = (icons[item.kind] or "") .. " " .. item.kind
            return item
          end,
        },
      })
    end,
  },
}
