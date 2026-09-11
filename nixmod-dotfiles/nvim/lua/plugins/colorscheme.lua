-- Catppuccin theme (matches helix, waybar, kitty)
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato",
        transparent_background = false,
        integrations = {
          cmp = false, -- using blink.cmp instead of nvim-cmp
          blink_cmp = true,
          treesitter = true,
          telescope = { enabled = true },
          neotree = true,
          gitsigns = true,
          which_key = true,
          indent_blankline = { enabled = true },
          native_lsp = { enabled = true },
          noice = true,
          notify = true,
          mason = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
