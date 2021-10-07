-- ensure pakcer is installed
local function ensure_packer_installed()
    -- if packer is also not installed as opt, install it
    local install_path = vim.fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
        vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    end
    -- load packer.nvim
    vim.cmd 'packadd packer.nvim'
end
ensure_packer_installed()

local function setup_basic_nvim_options()
    -- use <space> as leader key
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
setup_basic_nvim_options()

-- configuration
require('packer').startup({function(use)
    -- Packer can manage itself
    use {
        'wbthomason/packer.nvim',
        event = 'VimEnter',
    }
    -- Core
    use {
        'folke/which-key.nvim',
        config = function()
            require('which-key').setup()
            -- pre-defined mapping groups
            require('which-key').register(
                {
                    [ "b" ] = { name = "+buffer" },
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
        event = "BufWinEnter",
        setup = function()
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
                "",
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
        'shadmansaleh/lualine.nvim',
        after = 'nvim-web-devicons',
        config = function()
            require('lualine').setup()
        end
    }
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            { 'nvim-lua/plenary.nvim' },
        },
        module = "telescope",
        cmd = "Telescope",
        setup = function ()
            require('which-key').register(
                {
                    [ "bl" ] = {
                        "<cmd>lua require('telescope.builtin').buffers()<cr>",
                        "Lists open buffers"
                    },
                    [ "ff" ] = {
                        "<cmd>lua require('telescope.builtin').find_files()<cr>",
                        "Find file in your current working directory, respects .gitignore"
                    },
                    [ "fo" ] = {
                        "<cmd>lua require('telescope.builtin').file_browser()<cr>",
                        "Open file"
                    }
                },
                { prefix = "<leader>" }
            )
        end,
        config = function()
            require('telescope').setup()
        end
    }
    -- lsp
    use {
        'neovim/nvim-lspconfig',
        event = "BufRead",
        config = function()
            require('lspconfig')
        end
    }
    use {
        'williamboman/nvim-lsp-installer',
        after = "nvim-lspconfig",
        config = function()
            local lsp_installer = require("nvim-lsp-installer")
            lsp_installer.on_server_ready(function(server)
                local on_attach_callback = function(client, bufnr)
                    -- Enable lsp_signature
                    require("lsp_signature").on_attach()
                    -- Enable completion triggered by <c-x><c-o>
                    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
                    -- Register shortcut
                    require("which-key").register(
                        {
                            [ "la" ] = {
                                "<cmd>lua require('telescope.builtin').lsp_code_actions()<cr>",
                                "List Code Actions"
                            },
                            [ "ld" ] = {
                                "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>",
                                "Definition"
                            },
                            [ "lr" ] = {
                                "<cmd>lua require('telescope.builtin').lsp_references()<cr>",
                                "References"
                            },
                            [ "lR" ] = {
                                "<cmd>lua vim.lsp.buf.rename()<cr>",
                                "Rename"
                            },
                            [ "ls" ] = {
                                "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>",
                                "List symbols"
                            },
                        },
                        {
                            prefix = "<leader>",
                            buffer = bufnr,
                        }
                    )
                end

                local capabilities_fixed = vim.lsp.protocol.make_client_capabilities()
                capabilities_fixed = require("cmp_nvim_lsp").update_capabilities(capabilities_fixed)

                -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
                server:setup({
                    on_attach = on_attach_callback,
                    capabilities = capabilities_fixed
                })
                vim.cmd [[ do User LspAttachBuffers ]]
            end)
        end
    }
    use {
        "ray-x/lsp_signature.nvim",
        after = "nvim-lspconfig",
        config = function()
            require('lsp_signature').setup{
                bind = true,
                doc_lines = 2,
                floating_window = true,
                fix_pos = true,
                hint_enable = true,
                hint_prefix = " ",
                hint_scheme = "String",
                hi_parameter = "Search",
                max_height = 22,
                max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
                handler_opts = {
                   border = "single", -- double, single, shadow, none
                },
                zindex = 200, -- by default it will be on top of all floating windows, set to 50 send it to bottom
                padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc
            }
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
                module = "cmp_nvim_lsp",
                after = "nvim-lspconfig",
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
        module = "cmp",
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
            require('which-key').register (
                {
                    ["ft"] = {
                        "<cmd>NvimTreeToggle<cr>",
                        "Toggle Tree View"
                    },
                    ["fr"] = {
                        "<cmd>NvimTreeRefresh<cr>",
                        "Refresh Tree View"
                    },
                },
                { prefix = "<leader>" }
            )
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
