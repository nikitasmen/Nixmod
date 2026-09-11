-- which-key: shows available <leader> mappings as you type them, grouped
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git / worktree" },
        { "<leader>h", group = "Git hunk" },
        { "<leader>c", group = "Code" },
        { "<leader>x", group = "Diagnostics" },
        { "<leader>b", group = "Buffer" },
        { "<leader>t", group = "Terminal" },
        { "<leader>e", group = "Explorer" },
      },
    },
  },
}
