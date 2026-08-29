return {
  -- Mason: LSP installer
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
        },
      })
    end,
  },

    -- Mason-lspconfig bridge (Auto-installs rust-analyzer if you share your config with another machine)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "rust_analyzer", "gopls" },
        automatic_installation = true,
      })
    end,
  },

    -- LSP Configuration (Tells Neovim "when you open a .rs file, start rust-analyzer and talk to it")
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()

       -- Connect LSP to nvim-cmp for completions
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- Configure rust-analyzer
      vim.lsp.config('rust_analyzer', {
        cmd = { 'rust-analyzer' },
        root_markers = { 'Cargo.toml' },
        capabilities = capabilities,
      })

      -- Configure gopls 
      vim.lsp.config('gopls', {
        cmd = { 'gopls' },
        root_markers = { 'go.work', 'go.mod' },
        capabilities = capabilities,
        settings = {
            gopls = {
                gofumpt = true,
                usePlaceholders = true,
                completeUnimported = true,
            }
        }
      })


      -- Enable rust-analyzer when opening Rust files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rust',
        callback = function()
          vim.lsp.enable('rust_analyzer')
        end,
      })

       -- Enable Gopls when opening Go files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'go',
        callback = function()
          vim.lsp.enable('gopls')
        end,
      })

    end,
  },
}

