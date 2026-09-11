-- Small editing quality-of-life: bracket/quote auto-pairing, and comment
-- toggling with extra motions + treesitter-aware commentstring (Neovim's
-- native `gc`/`gcc` already exists since 0.10, this adds gcO/gco/gcA and
-- correct comments inside embedded languages like JSX).
return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  {
    "numToStr/Comment.nvim",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    event = "VeryLazy",
    config = function()
      require("ts_context_commentstring").setup({ enable_autocmd = false })
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
}
