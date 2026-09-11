-- LSP: mason installs servers, mason-lspconfig enables them, nvim-lspconfig
-- ships the default per-server configs consumed by Neovim's native
-- vim.lsp.config()/vim.lsp.enable() API.
--
-- To support a language NOT in `ensure_installed` below: run `:Mason`, install
-- any server from the list (search with `/`), and mason-lspconfig will call
-- vim.lsp.enable() for it automatically (automatic_enable = true) -- no config
-- edit needed. Only add a server to `ensure_installed` if you want it
-- installed automatically on every machine this config is synced to.
--
-- NOTE: nixd is NOT in Mason's registry (only nixfmt/nixpkgs-fmt/rnix-lsp
-- are), so it's installed as a Nix system package instead -- see
-- nixmod-system/modules/programs/development.nix -- and enabled explicitly
-- below rather than through mason-lspconfig.
return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {},
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "ts_ls", "html", "cssls", "tailwindcss", "jsonls",
        "pyright",
      },
      automatic_enable = true,
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "folke/lazydev.nvim" },
    config = function()
      vim.diagnostic.config({
        virtual_text = false, -- tiny-inline-diagnostic (see diagnostics.lua) renders this instead
        underline = true,
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
          },
        },
        float = { border = "rounded", source = true },
      })

      -- Per-server tweaks (only needed when defaults aren't enough)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      -- nixd comes from the Nix system package, not Mason (see note above),
      -- so it has to be enabled explicitly.
      vim.lsp.config("nixd", {
        settings = {
          nixd = {
            formatting = { command = { "nixfmt" } },
          },
        },
      })
      vim.lsp.enable("nixd")

      -- Buffer-local keymaps: only defined once an LSP client actually attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("nixmod-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
          end

          map("n", "gd", function() require("telescope.builtin").lsp_definitions() end, "Goto definition")
          map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
          map("n", "gi", function() require("telescope.builtin").lsp_implementations() end, "Goto implementation")
          map("n", "gr", function() require("telescope.builtin").lsp_references() end, "Goto references")
          map("n", "gy", function() require("telescope.builtin").lsp_type_definitions() end, "Goto type definition")
          map("n", "K", vim.lsp.buf.hover, "Hover documentation")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>cr", function() require("inc_rename").rename() end, "Rename symbol")
          map("n", "<leader>cs", function() require("telescope.builtin").lsp_document_symbols() end, "Document symbols")
          map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
          map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")

          -- Highlight all references of the symbol under the cursor
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/documentHighlight") then
            local hl_group = vim.api.nvim_create_augroup("nixmod-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = hl_group,
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = hl_group,
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    end,
  },

  -- Live-preview rename (used by <leader>cr above)
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {},
  },
}
