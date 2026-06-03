-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy with plugins
require("lazy").setup({
    -- imports
    { import = "plugins.cmp" },
    { import = "plugins.lsp" },

    -------------
    -- plugins --
    -------------

    -- Telescope
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
          require('telescope').setup({
            defaults = {
              layout_config = {
                horizontal = { preview_width = 0.55 },
              },
            },
          })
          
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
          vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
          vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
        end,
    },

    -- File Explorer
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
          -- Disable netrw (default file explorer)
          vim.g.loaded_netrw = 1
          vim.g.loaded_netrwPlugin = 1

          require("nvim-tree").setup({
            view = {
              width = 35,
            },
            renderer = {
              group_empty = true,
              icons = {
                show = {
                  file = false,
                  folder = false, 
                  folder_arrow = true,
                  git = false,
                },
              },
            },
            -- filters = {
            --   dotfiles = false, -- Show hidden files
            --   custom = { "^.git$", "^target$" }, -- Hide .git and target dirs
            -- },
          })

        end,
    },

    -- Treesitter 
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
          require("nvim-treesitter.configs").setup({
            -- Install parsers for these languages
            ensure_installed = { "rust", "lua", "toml", "json", "markdown", "javascript", "typescript" },
            
            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,
            
            -- Automatically install missing parsers when entering buffer
            auto_install = true,
            
            highlight = {
              enable = true,
            },
            
            indent = {
              enable = true,
            },
          })
        end,
    },

    -- Theme Gruvbox
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function() 
            require("gruvbox").setup({
                italic = { 
                    strings = false, 
                    comments = true, 
                    keywords = true,  -- highlight things like 'if', 'for', 'return'
                    -- folds = true,
                },

                palette_overrides = {
                    dark0_hard = "#1b1b1b",  -- darker base background
                    bright_green = "#a9b665", -- tweak bright green
                },
                bold = true,  -- make some keywords bold
                contrast = 'hard',
                underline = true,
            })

            vim.o.background = "dark"
            vim.cmd("colorscheme gruvbox")
        end
    },

    -- Git Signs
    {
        "lewis6991/gitsigns.nvim",
        config = function()
          require('gitsigns').setup({
            signs = {
              add          = { text = '│' },
              change       = { text = '│' },
              delete       = { text = '_' },
              topdelete    = { text = '‾' },
              changedelete = { text = '~' },
            },
            -- current_line_blame = true, -- Toggle with :Gitsigns toggle_current_line_blame
          })
        end,
    },

    -- Comment toggle
    {
        "numToStr/Comment.nvim",
        config = function()
          require('Comment').setup()
        end,
    },

    -- Auto pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
          require("nvim-autopairs").setup({
            check_ts = true, -- Use treesitter
            ts_config = {
              lua = {'string'},
              rust = {'string'},
            },
            fast_wrap = {
              map = '<M-e>',
              chars = { '{', '[', '(', '"', "'" },
              pattern = [=[[%'%"%>%]%)%}%,]]=],
              end_key = '$',
              keys = 'qwertyuiopzxcvbnmasdfghjkl',
              check_comma = true,
              highlight = 'Search',
              highlight_grey='Comment'
            },
          })
        end,
    },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        config = function()
          local battery_percentage = nil 

          require('lualine').setup({
            options = {
              icons_enabled = false,
              theme = 'auto',
              component_separators = { left = '|', right = '|'},
              section_separators = { left = '', right = ''},
            },
            sections = {
              lualine_a = {'mode'},
              lualine_b = {'branch', 'diff', 'diagnostics'},
              lualine_c = {'filename'},
              lualine_x = {'encoding', 'fileformat', 'filetype'},
              lualine_y = {{
                        -- update battery_percentage
                        function()
                            local handle = io.popen("cat /sys/class/power_supply/BAT0/capacity 2>/dev/null")
                            if not handle then
                                return "NO BAT"
                            end

                            local capacity = handle:read("*a"):gsub("%s+", "")
                            handle:close()

                            battery_percentage = tonumber(capacity)
                            return battery_percentage 
                        end,

                        -- read battery_percentage
                        color = function()
                            if not battery_percentage then
                                return {fg = "#ffffff", bg = "#b8bb26"}
                            end
                            
                            if battery_percentage < 30 then
                                return {fg = "#1d2021", bg = "#fb4934"}
                            elseif battery_percentage < 36 then
                                return {fg = "#1d2021", bg = "#fe8019"}
                            elseif battery_percentage > 96 then
                                return {fg = "#1d2021", bg = "#fb4934"}
                            end

                            return nil
                        end

                    }},
              lualine_z = {
                        function()
                            return os.date("%H:%M")
                        end
                    }
            },
          })
        end,
    },
    
}, {
  ui = {
    border = "rounded",
  },
  change_detection = {
    notify = false,
  },
})
