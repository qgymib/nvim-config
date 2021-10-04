-- ensure pakcer is installed
local function ensure_packer_installed()
    -- check if packer is installed as startup plugin
    local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if vim.fn.empty(vim.fn.glob(install_path)) <= 0 then
        return
    end
    -- if packer is also not installed as opt, install it
    local install_opt_path = vim.fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
    if vim.fn.empty(vim.fn.glob(install_opt_path)) > 0 then
        vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_opt_path})
    end
    -- load packer.nvim
    vim.cmd 'packadd packer.nvim'
end
ensure_packer_installed()

local function setup_basic()
    vim.g.mapleader = " "
    vim.opt.timeoutlen = 400
    vim.opt.termguicolors = true
    vim.opt.title = true
    vim.opt.clipboard = "unnamedplus"
    vim.opt.cmdheight = 1
    vim.opt.cul = true
    -- disable tilde on end of buffer: https://github.com/neovim/neovim/pull/8546#issuecomment-643643758
    vim.opt.fillchars = { eob = " " }
    vim.opt.hidden = true
    vim.opt.ignorecase = true
    vim.opt.mouse = "a"
    -- Numbers
    vim.opt.number = true
    vim.opt.ruler = false
    -- Don't show any numbers inside terminals
    vim.cmd [[ au TermOpen term://* setlocal nonumber norelativenumber | setfiletype terminal ]]
    vim.opt.signcolumn = "number"
    vim.opt.splitbelow = true
    vim.opt.splitright = true
    vim.cmd[[filetype plugin indent on]]
    vim.o.smarttab = true
    vim.o.autoindent = true
    vim.o.smartindent = true
    vim.o.shiftwidth = 4
    vim.o.tabstop = 4
    vim.o.softtabstop = 4
    vim.o.expandtab = true
    vim.o.statusline='%f  %y%m%r%h%w%=[%l,%v]      [%L,%p%%] %n'
end
setup_basic()

-- configuration
require('packer').startup({function(use)
    -- Packer can manage itself
    use {
        'wbthomason/packer.nvim',
        event = 'VimEnter',
        config = function()
            vim.cmd([[
                augroup packer_user_config
                  autocmd!
                  autocmd BufWritePost init.lua source <afile> | PackerCompile
                augroup end
            ]])
        end
    }
    -- Core
    use {
        'folke/which-key.nvim',
        config = function()
            require('which-key').setup()
            -- pre-defined mapping groups
            require('which-key').register(
                {
                    [ "f" ] = { name = "+file" },
                    [ "l" ] = { name = "+lsp" },
                    [ "m" ] = { name = "+misc" }
                },
                { prefix = "<leader>" }
            )
        end,
    }
    -- UI
    use {
        'navarasu/onedark.nvim',
        after = 'packer.nvim',
        config = function()
            vim.cmd[[colorscheme onedark]]
        end
    }
    use {
        'nvim-treesitter/nvim-treesitter',
        branch = "0.5-compat",
        event = "BufRead",
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = "lua",
                highlight = {
                    enable = true,
                }
            }
        end
    }
    use {
        'kyazdani42/nvim-web-devicons',
        after = 'onedark.nvim',
        config = function()
            require('nvim-web-devicons').setup {
                default = true
            }
        end
    }
    use {
        'glepnir/dashboard-nvim',
        setup = function()
            vim.cmd[[
                autocmd FileType dashboard set showtabline=0 | autocmd WinLeave <buffer> set showtabline=2
            ]]
            require('which-key').register {
                [ "<leader>md" ] = {
                    "<cmd>Dashboard<cr>",
                    "Open Dashboard"
                }
            }
        end,
        config = function()
            vim.g.dashboard_default_executive = 'telescope'
            vim.g.dashboard_custom_header = {
                "",
                "",
                "",
                "       .--.           .---.        .-.",
                "   .---|--|   .-.     | A |  .---. |~|    .--.",
                ".--|===|Ch|---|_|--.__| S |--|:::| |~|-==-|==|---.",
                "|%%|NT2|oc|===| |~~|%%| C |--|   |_|~|CATS|  |___|-.",
                "|  |   |ah|===| |==|  | I |  |:::|=| |    |GB|---|=|",
                "|  |   |ol|   |_|__|  | I |__|   | | |    |  |___| |",
                "|~~|===|--|===|~|~~|%%|~~~|--|:::|=|~|----|==|---|=|",
                "^--^---'--^---^-^--^--^---'--^---^-^-^-==-^--^---^-'",
                "",
            }
            vim.g.dashboard_custom_section = {
                a = {
                    description = { "  New File           " },
                    command = "DashboardNewFile",
                },
                b = {
                    description = { "  Find File          " },
                    command = "Telescope find_files",
                },
                c = {
                    description = { "  Recent Projects    " },
                    command = "Telescope projects",
                },
                d = {
                    description = { "  Recently Used Files" },
                    command = "Telescope oldfiles",
                },
                e = {
                    description = { "  Configuration      " },
                    command = ":e " .. vim.fn.stdpath('config') .. "/init.lua"
                },
            }
            vim.g.dashboard_custom_footer = {
                "   ",
            }
        end
    }
    use {
        'lukas-reineke/indent-blankline.nvim',
        event = "BufRead",
        config = function()
            require('indent_blankline').setup {
                filetype_exclude = {
                   "help",
                   "terminal",
                   "dashboard",
                   "packer",
                   "lspinfo",
                   "TelescopePrompt",
                   "TelescopeResults",
                },
                buftype_exclude = { "terminal" },
                show_trailing_blankline_indent = false,
                show_first_indent_level = false,
            }
        end
    }
    use {
        'akinsho/bufferline.nvim',
        after = 'nvim-web-devicons',
        config = function()
            require("bufferline").setup {
            }
        end
    }
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            { 'nvim-lua/plenary.nvim' },
            {
                'nvim-telescope/telescope-fzf-native.nvim',
            },
        },
        module = "telescope",
        cmd = "Telescope",
        config = function()
            require('telescope').setup {
                fzf = {
                    fuzzy = true,                   -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true,    -- override the file sorter
                    case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                                                    -- the default case_mode is "smart_case"
                }
            }
            -- Get fzf loaded and working with telescope
            require('telescope').load_extension('fzf')
        end
    }
    -- lsp
    use {
        'neovim/nvim-lspconfig',
        requires = {
            {
                'williamboman/nvim-lsp-installer',
                config = function()
                    local lsp_installer = require("nvim-lsp-installer")
                    lsp_installer.on_server_ready(function(server)
                        local on_attach = function(client, bufnr)
                            -- Enable completion triggered by <c-x><c-o>
                            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
                            require("which-key").register(
                                {
                                    [ "lD" ] = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "Declaration" },
                                    [ "ld" ] = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Definition" },
                                    [ "lr" ] = { "<cmd>lua vim.lsp.buf.references()<CR>", "References" },
                                    [ "lR" ] = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
                                },
                                {
                                    prefix = "<leader>",
                                    buffer = bufnr,
                                }
                            )
                        end

                        -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
                        server:setup({ on_attach = on_attach })
                        vim.cmd [[ do User LspAttachBuffers ]]
                    end)
                end
            },
        },
        opt = true,
        setup = function()
            vim.defer_fn(function()
                require("packer").loader('nvim-lspconfig')
            end, 0)
            -- reload the current file so lsp actually starts for it
            vim.defer_fn(function()
                vim.cmd 'if &ft == "packer" | echo "" | else | silent! e %'
            end, 0)
        end,
        config = function()
            require('lspconfig')
        end
    }
    -- Auto completion
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            {
                'rafamadriz/friendly-snippets',
                event = "InsertEnter",
            },
            {
                'L3MON4D3/LuaSnip',
                wants = 'friendly-snippets',
                after = 'nvim-cmp',
                config = function()
                    require('luasnip').config.set_config {
                        history = true,
                        updateevents = "TextChanged,TextChangedI",
                    }
                end
            },
            {
                'saadparwaiz1/cmp_luasnip',
                after = 'LuaSnip',
            },
            {
                'hrsh7th/cmp-nvim-lua',
                after = 'cmp_luasnip',
            },
            {
                'hrsh7th/cmp-nvim-lsp',
                after = 'cmp-nvim-lua',
            },
            {
                'hrsh7th/cmp-buffer',
                after = 'cmp-nvim-lsp',
            },
            {
                'hrsh7th/cmp-path',
                after = 'cmp-buffer',
            },
            {
                'windwp/nvim-autopairs',
                after = 'nvim-cmp',
                config = function()
                    require('nvim-autopairs').setup {}
                    require("nvim-autopairs.completion.cmp").setup {
                        map_cr = true, --  map <CR> on insert mode
                        map_complete = true, -- it will auto insert `(` (map_char) after select function or method item
                        auto_select = true, -- automatically select the first item
                        insert = false, -- use insert confirm behavior instead of replace
                        map_char = { -- modifies the function or method delimiter by filetypes
                            all = '(',
                            tex = '{'
                        }
                    }
                end
            },
        },
        after = 'friendly-snippets',
        config = function()
            local cmp = require('cmp')
            cmp.setup {
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = {
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.close(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                    { name = 'nvim_lua' },
                    { name = 'path' },
                }
            }
        end
    }
    -- Misc
    use {
        'kyazdani42/nvim-tree.lua',
        requires = 'kyazdani42/nvim-web-devicons',
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        config = function()
            require('nvim-tree').setup {
                ignore_ft_on_setup = { "dashboard" },
            }
        end,
        setup = function()
            require('which-key').register {
                ["<leader>ft"] = {
                    "<cmd>NvimTreeToggle<cr>",
                    "Toggle Tree View"
                },
                ["<leader>fr"] = {
                    "<cmd>NvimTreeRefresh<cr>",
                    "Refresh Tree View"
                },
            }
        end
    }
end,
config = {
    display = {
        open_fn = function()
            return require('packer.util').float({ border = 'single' })
        end
    }
}
})
