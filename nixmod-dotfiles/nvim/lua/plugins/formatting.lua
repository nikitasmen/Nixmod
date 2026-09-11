-- Formatting (conform.nvim) + linting (nvim-lint), with mason-tool-installer
-- making sure the underlying binaries exist on every machine this is synced to.
--
-- To add another language: add its mason package name to `ensure_installed`
-- below, then map its filetype in `formatters_by_ft`/`linters_by_ft`.
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "stylua", -- lua formatter
        "shfmt", "shellcheck", -- shell format + lint
        "prettierd", "prettier", -- web formatter (prettierd is faster, prettier is the fallback)
        "eslint_d", -- web lint
        "ruff", -- python format + lint (single mason package covers both roles)
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = "ConformInfo",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        nix = { "nixfmt" }, -- from nixpkgs (nixfmt-rfc-style), see nixmod-system/modules/programs/development.nix
        python = { "ruff_format" },
        sh = { "shfmt" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return nil
        end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufEnter", "InsertLeave" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        nix = { "statix" }, -- from nixpkgs, see nixmod-system/modules/programs/development.nix
        python = { "ruff" },
        sh = { "shellcheck" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nixmod-lint", { clear = true }),
        callback = function()
          -- ignore_errors: don't spam an error the first time a linter binary
          -- hasn't finished installing yet (mason-tool-installer runs async on startup)
          lint.try_lint(nil, { ignore_errors = true })
        end,
      })
    end,
  },
}
