-- Statusline, buffer tabs, indent guides, and start screen
return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "catppuccin",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
      },
      sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics", "encoding", "filetype" },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        always_show_bufferline = false, -- hide when only the dashboard/one buffer is open
        separator_style = "thin",
        show_buffer_close_icons = true,
        show_close_icon = false,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = { "neo-tree", "lazy", "mason", "alpha", "help", "trouble" },
      },
    },
  },

  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      -- theta theme: header + a recent-files list + buttons + (below) a
      -- plugin-count/startup-time footer -- more info than the plain
      -- "dashboard" theme, which is just a header and buttons.
      local theta = require("alpha.themes.theta")
      local dashboard = require("alpha.themes.dashboard")

      theta.header.val = {
        "                                                     ",
        "  ███╗   ██╗██╗██╗  ██╗███╗   ███╗ ██████╗ ██████╗   ",
        "  ████╗  ██║██║╚██╗██╔╝████╗ ████║██╔═══██╗██╔══██╗  ",
        "  ██╔██╗ ██║██║ ╚███╔╝ ██╔████╔██║██║   ██║██║  ██║  ",
        "  ██║╚██╗██║██║ ██╔██╗ ██║╚██╔╝██║██║   ██║██║  ██║  ",
        "  ██║ ╚████║██║██╔╝ ██╗██║ ╚═╝ ██║╚██████╔╝██████╔╝  ",
        "  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═════╝   ",
        "                                                     ",
      }
      theta.header.opts.hl = "AlphaHeader"

      theta.buttons.val = {
        { type = "text", val = "Quick links", opts = { hl = "SpecialComment", position = "center" } },
        { type = "padding", val = 1 },
        dashboard.button("f", "  Find file", function() require("telescope.builtin").find_files() end),
        dashboard.button("g", "  Live grep", function() require("telescope.builtin").live_grep() end),
        dashboard.button("n", "  New file", "<cmd>ene<cr>"),
        dashboard.button("c", "  Edit config", function()
          require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
        end),
        dashboard.button("u", "  Update plugins", "<cmd>Lazy sync<cr>"),
        dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
      }

      local footer = {
        type = "text",
        val = function()
          local stats = require("lazy").stats()
          local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
          local v = vim.version()
          return string.format(
            "󱐌 %d/%d plugins loaded in %sms  •  Neovim v%d.%d.%d",
            stats.loaded, stats.count, ms, v.major, v.minor, v.patch
          )
        end,
        opts = { position = "center", hl = "AlphaFooter" },
      }

      local config = vim.deepcopy(theta.config)
      table.insert(config.layout, { type = "padding", val = 1 })
      table.insert(config.layout, footer)

      alpha.setup(config)
    end,
  },
}
