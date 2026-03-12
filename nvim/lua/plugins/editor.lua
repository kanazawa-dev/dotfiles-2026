return {
  -- ── Explorador de archivos ─────────────────────────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    opts = {
      window = { width = 30 },
      filesystem = {
        filtered_items = { visible = false, hide_dotfiles = false, hide_gitignored = false },
        follow_current_file = { enabled = true },
      },
    },
  },

  -- ── Telescope (fuzzy finder) ───────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    opts = {
      defaults = {
        prompt_prefix    = "  ",
        selection_caret  = " ",
        border           = true,
        layout_strategy  = "horizontal",
        sorting_strategy = "ascending",
        layout_config    = { prompt_position = "top" },
        file_ignore_patterns = { "node_modules", ".git/", "dist/" },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
    end,
  },

  -- ── Which-key (ver atajos al presionar leader) ─────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>f", group = "Buscar" },
        { "<leader>l", group = "LSP" },
        { "<leader>g", group = "Git" },
        { "<leader>b", group = "Buffers" },
      },
    },
  },

  -- ── Git signs en el gutter ─────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
      },
    },
  },

  -- ── LazyGit integrado ─────────────────────────────────────────────────
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "LazyGit",
  },

  -- ── Terminal flotante ──────────────────────────────────────────────────
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size      = 15,
      direction = "horizontal",
      border    = "curved",
      shade_terminals = true,
    },
  },

  -- ── Comentarios rápidos ────────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    event = "BufReadPost",
    opts  = {},
  },

  -- ── Auto-pares de brackets ─────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event  = "InsertEnter",
    opts   = { check_ts = true },
  },

  -- ── Highlight de palabra bajo cursor ──────────────────────────────────
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    config = function()
      require("illuminate").configure({ delay = 200 })
    end,
  },

  -- ── Búsqueda mejorada con flash ────────────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts  = {},
    keys  = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },

  -- ── Treesitter (syntax avanzado) ──────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    opts = {
      ensure_installed = { "lua", "python", "javascript", "typescript", "tsx",
                           "json", "yaml", "toml", "markdown", "bash", "sql" },
      highlight        = { enable = true },
      indent           = { enable = true },
      incremental_selection = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
