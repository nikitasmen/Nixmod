-- blink.cmp: completion engine (LSP, path, snippets, buffer)
-- lazydev: makes lua_ls fast + accurate when editing this very config
return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- tracks tagged releases; if `:Lazy sync` can't find a match,
    -- drop this `version` field to track main instead.
    dependencies = { "rafamadriz/friendly-snippets" },
    event = "InsertEnter",
    opts = {
      keymap = { preset = "default" }, -- <CR> confirm, <C-n>/<C-p> or arrows to navigate
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = { border = "rounded" },
        list = { selection = { preselect = false, auto_insert = false } },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },

  -- Neovim Lua API/plugin-source aware completion + type info for editing this config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
