-- Neovim keymaps
local keymap = vim.keymap.set

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Neo-tree: file explorer (Space+e = toggle, Space+E = reveal current file)
keymap("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })
keymap("n", "<leader>E", "<cmd>Neotree reveal<cr>", { desc = "Reveal current file in explorer" })

-- Toggleterm: integrated terminal (Space+t = toggle, Space+T = new terminal)
keymap("n", "<leader>t", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
keymap("n", "<leader>T", "<cmd>ToggleTerm size=20 direction=horizontal<cr>", { desc = "Toggle horizontal terminal" })
keymap("t", "<C-\\>", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal (from terminal mode)" })

-- Git worktree: Space+g for worktree operations
keymap("n", "<leader>gw", function()
  require("telescope").extensions.git_worktree.git_worktrees()
end, { desc = "Switch git worktree" })
keymap("n", "<leader>gc", function()
  require("telescope").extensions.git_worktree.create_git_worktree()
end, { desc = "Create git worktree" })
-- <leader>gg (LazyGit) is defined in lua/plugins/terminal.lua
-- Gitsigns hunk keymaps (<leader>h*) are buffer-local, defined in lua/plugins/git.lua

-- Neo-tree's git_status source: stage/unstage/commit/push/pull/revert files
-- from inside the explorer sidebar (no separate LazyGit popup needed for
-- this). Opens as another tab in the same sidebar -- switch tabs with `<`/
-- `>`, or click Files/Buffers/Git in the winbar. Once inside: A=stage all,
-- ga=stage file, gu=unstage, gt=toggle stage, gr=revert, gc=commit,
-- gp=push, gl=pull, gg=commit+push.
keymap("n", "<leader>gs", "<cmd>Neotree show git_status<cr>", { desc = "Git status (explorer)" })

-- Telescope: fuzzy finding
keymap("n", "<leader>ff", function() require("telescope.builtin").find_files() end, { desc = "Find files" })
keymap("n", "<leader>fg", function() require("telescope.builtin").live_grep() end, { desc = "Live grep" })
keymap("n", "<leader>fb", function() require("telescope.builtin").buffers() end, { desc = "Find buffers" })
keymap("n", "<leader>fh", function() require("telescope.builtin").help_tags() end, { desc = "Help tags" })
keymap("n", "<leader>fr", function() require("telescope.builtin").oldfiles() end, { desc = "Recent files" })
keymap("n", "<leader>fs", function() require("telescope.builtin").grep_string() end, { desc = "Grep word under cursor" })
keymap("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs" })

-- Buffers
keymap("n", "<leader>bn", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
keymap("n", "<leader>bp", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
keymap("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
keymap("n", "<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted then
      vim.api.nvim_buf_delete(buf, {})
    end
  end
end, { desc = "Close other buffers" })

-- Diagnostics (Trouble)
keymap("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle diagnostics" })
keymap("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
keymap("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list" })

-- Code: formatting (LSP-attach keymaps like gd/gr/K/<leader>ca live in lua/plugins/lsp.lua)
keymap("n", "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
