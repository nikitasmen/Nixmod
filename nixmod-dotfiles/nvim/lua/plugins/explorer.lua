-- Neo-tree: file explorer sidebar
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        sources = { "filesystem", "buffers", "git_status" },
        -- Git status column in the filesystem tree, plus a dedicated
        -- git_status source (stage/unstage/commit/push/pull/revert -- see
        -- <leader>gs below) so you don't need a separate LazyGit popup for
        -- simple file-level git actions.
        enable_git_status = true,
        git_status_async = true,
        source_selector = {
          winbar = true, -- clickable Files/Buffers/Git tabs at the top of the sidebar
          show_scrolled_off_parent_node = true,
        },
        filesystem = {
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
          respect_gitignore = true,
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = true,
          },
        },
        window = {
          position = "left",
          width = 35,
          mappings = {
            ["<space>"] = { "toggle_node", nowait = false },
            ["<cr>"] = "open",
            ["o"] = "open",
            ["<esc>"] = "cancel",
            ["P"] = { "toggle_preview", config = { use_float = true } },
            ["l"] = "open",
            ["h"] = "close_node",
            ["z"] = "close_all_nodes",
            ["Z"] = "expand_all_nodes",
            ["a"] = { "add", config = { show_path = "none" } },
            ["d"] = "delete",
            ["r"] = "rename",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["c"] = "copy",
            ["m"] = "move",
            ["q"] = "close_window",
            ["R"] = "refresh",
          },
        },
      })

      -- Always show the explorer on the left, like an IDE sidebar, instead
      -- of requiring <leader>e first. `nested = true` lets this autocmd
      -- trigger other autocommands (e.g. alpha's dashboard) normally.
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("nixmod-neotree-autoopen", { clear = true }),
        nested = true,
        callback = function()
          local cur_win = vim.api.nvim_get_current_win()
          require("neo-tree.command").execute({ action = "show", position = "left", source = "filesystem" })
          if vim.api.nvim_win_is_valid(cur_win) then
            vim.api.nvim_set_current_win(cur_win)
          end
        end,
      })
    end,
  },
}
