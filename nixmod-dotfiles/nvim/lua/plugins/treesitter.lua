-- Treesitter: syntax highlighting, indentation, folding, textobjects
--
-- nvim-treesitter's `main` branch (the current default, a full rewrite) no
-- longer auto-enables anything or takes a `configs.setup()` table: parsers
-- are installed explicitly, and each feature (highlight/indent/fold) is wired
-- up per-filetype via a FileType autocommand. See :h nvim-treesitter-commands.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- this plugin does not support lazy-loading
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    config = function()
      local ts = require("nvim-treesitter")

      -- Parsers to have ready on startup; anything else is installed
      -- on-demand (see the FileType autocmd below) the first time you open
      -- a filetype for it -- no config edit needed to pick up a new language.
      ts.install({
        "lua", "vim", "vimdoc", "query",
        "nix",
        "javascript", "typescript", "tsx", "html", "css", "json", "yaml",
        "python",
        "bash", "markdown", "markdown_inline", "regex", "diff", "gitignore",
      })

      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("nixmod-treesitter", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match) or ev.match

          if not vim.tbl_contains(ts.get_installed(), lang) then
            if vim.tbl_contains(ts.get_available(), lang) then
              ts.install({ lang })
            else
              return -- no parser exists for this filetype at all
            end
          end

          pcall(vim.treesitter.start)
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      local select_textobject = function(query)
        return function()
          require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
        end
      end
      vim.keymap.set({ "x", "o" }, "af", select_textobject("@function.outer"), { desc = "Select function (outer)" })
      vim.keymap.set({ "x", "o" }, "if", select_textobject("@function.inner"), { desc = "Select function (inner)" })
      vim.keymap.set({ "x", "o" }, "ac", select_textobject("@class.outer"), { desc = "Select class (outer)" })
      vim.keymap.set({ "x", "o" }, "ic", select_textobject("@class.inner"), { desc = "Select class (inner)" })
    end,
  },
}
