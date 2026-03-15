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
