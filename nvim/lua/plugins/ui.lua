return {
  -- ── Tema Catppuccin (igual que Ghostty) ────────────────────────────────
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "auto",
      background = {
        light = "latte",
        dark  = "mocha",
      },
      transparent_background = true,
      integrations = {
        treesitter   = true,
        telescope    = true,
        neo_tree     = true,
        cmp          = true,
        gitsigns     = true,
        which_key    = true,
        indent_blankline = { enabled = true },
        native_lsp   = { enabled = true },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd("colorscheme catppuccin")
    end,
  },

  -- ── Statusline ─────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme                = "catppuccin",
        globalstatus         = true,
        component_separators = { left = "│", right = "│" },
        section_separators   = { left = "", right = "" },
      },
      sections = {
        lualine_a = { { "mode", icon = "" } },
        lualine_b = { { "branch", icon = "" }, "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- ── Bufferline (tabs de archivos) ──────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    event   = "VeryLazy",
    version = "*",
    opts = {
      options = {
        diagnostics           = "nvim_lsp",
        always_show_bufferline = false,
        offsets = {
          { filetype = "neo-tree", text = "Explorer", highlight = "Directory", text_align = "center" },
        },
      },
    },
  },

  -- ── Iconos ─────────────────────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── Indent guides ──────────────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main  = "ibl",
    event = "BufReadPost",
    opts  = { scope = { enabled = true } },
  },

  -- ── UI mejorada para inputs/selects ────────────────────────────────────
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
    end,
  },

  -- ── Dashboard de inicio ────────────────────────────────────────────────
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = {
      theme = "doom",
      config = {
        header = {
          "",
          " ██╗  ██╗ █████╗ ███╗   ██╗ █████╗ ███████╗ █████╗ ██╗    ██╗ █████╗ ",
          " ██║ ██╔╝██╔══██╗████╗  ██║██╔══██╗╚══███╔╝██╔══██╗██║    ██║██╔══██╗",
          " █████╔╝ ███████║██╔██╗ ██║███████║  ███╔╝ ███████║██║ █╗ ██║███████║",
          " ██╔═██╗ ██╔══██║██║╚██╗██║██╔══██║ ███╔╝  ██╔══██║██║███╗██║██╔══██║",
          " ██║  ██╗██║  ██║██║ ╚████║██║  ██║███████╗██║  ██║╚███╔███╔╝██║  ██║",
          " ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝",
          "",
        },
        center = {
          { icon = "  ", desc = "Nuevo archivo      ", key = "n", action = "enew" },
          { icon = "  ", desc = "Buscar archivo     ", key = "f", action = "Telescope find_files" },
          { icon = "  ", desc = "Archivos recientes ", key = "r", action = "Telescope oldfiles" },
          { icon = "  ", desc = "Buscar texto       ", key = "g", action = "Telescope live_grep" },
          { icon = "  ", desc = "LazyGit            ", key = "G", action = "LazyGit" },
          { icon = "󰒲  ", desc = "Plugins (Lazy)     ", key = "p", action = "Lazy" },
          { icon = "  ", desc = "Salir              ", key = "q", action = "qa" },
        },
        footer = { "", "✦ Kanazawa" },
      },
    },
  },

  -- ── Notificaciones bonitas ─────────────────────────────────────────────
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
      render            = "minimal",
      stages            = "fade",
      timeout           = 3000,
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
    end,
  },
}
