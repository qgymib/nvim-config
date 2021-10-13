-- Global configuration storage
QConfig = {}
QConfig.fn = {}

-- basic nvim options
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
    vim.cmd[[au TermOpen term://* setlocal nonumber norelativenumber | setfiletype terminal]]
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
    vim.o.statusline = '%f  %y%m%r%h%w%=[%l,%v]      [%L,%p%%] %n'
    vim.o.scrolloff = 3

    -- key map
    vim.api.nvim_set_keymap('n', "<Home>", [[<cmd>lua QConfig.fn.LineHome()<cr>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('i', "<Home>", [[<cmd>lua QConfig.fn.LineHome()<cr>]], { noremap = true, silent = true })
end
setup_basic_nvim_options()

-- global key mappings
QConfig.which_key = {
    normal_mode = {
        b = {
            name = "+buffer",
            l = { "<cmd>lua require('telescope.builtin').buffers()<cr>", "Lists open buffers" },
            j = { "<cmd>lua require('telescope.builtin').jumplist()<cr>", "Jump list" },
        },
        f = {
            name = "+file",
            o = { "<cmd>lua require('telescope.builtin').file_browser()<cr>", "Open file" },
            t = { "<cmd>NvimTreeToggle<cr>", "Toggle Tree View" },
            r = { "<cmd>NvimTreeRefresh<cr>", "Refresh Tree View" },
            p = { "<cmd>Telescope projects<cr>", "Open project" },
        },
        m = {
            name = "+misc",
            d = { "<cmd>Dashboard<cr>", "Open Dashboard" },
            m = { "<cmd>lua require('telescope.builtin').marks()<cr>", "Book marks" },
            p = { "<cmd>lua require('telescope.builtin').builtin()<cr>", "Telescope pickers" },
        },
        p = {
            name = "+packer",
            c = { "<cmd>PackerCompile<cr>", "Compile" },
            C = { "<cmd>PackerClean<cr>", "Clean" },
            i = { "<cmd>PackerInstall<cr>", "Install" },
            s = { "<cmd>PackerStatus<cr>", "Status" },
            S = { "<cmd>PackerSync<cr>", "Sync" },
            u = { "<cmd>PackerUpdate<cr>", "Update" },
        },
        s = {
            name = "+search",
            f = { "<cmd>lua require('telescope.builtin').find_files()<cr>", "Find files (respects .gitignore)"},
            w = { "<cmd>lua require('telescope.builtin').grep_string()<cr>", "Find cursor word" },
            s = { "<cmd>lua require('telescope.builtin').live_grep()<cr>", "Find string" },
        },
        t = {
            name = "+terminal",
            t = { "<cmd>ToggleTerm<cr>", "Toggle terminal" },
        }
    },
    lsp_mode = {
        l = {
            name = "+lsp",
            a = { "<cmd>lua require('telescope.builtin').lsp_code_actions()<cr>", "List Code Actions" },
            d = { "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>", "Definition" },
            o = { "<cmd>SymbolsOutline<cr>", "Outline" },
            r = { "<cmd>lua require('telescope.builtin').lsp_references()<cr>", "References" },
            R = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
            s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Signature help" },
            S = { "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", "List symbols" },
        }
    },
}

--- Goto the beginning of first non-whitespace character in line
QConfig.fn.LineHome = function ()
    local x = vim.fn.col('.')
    vim.cmd[[execute "normal ^"]]
    if x == vim.fn.col('.') then
        vim.cmd[[execute "normal 0"]]
    end
end

-- ensure pakcer is installed
local function ensure_packer_installed()
    -- if packer is also not installed as opt, install it
    local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if vim.fn.empty(vim.fn.glob(install_path)) == 0 then
        return
    end
    -- load packer.nvim
    vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd 'packadd packer.nvim'
end
ensure_packer_installed()

-- configuration
require('packer').startup({function(use)
    -- Packer can manage itself
    use { 'wbthomason/packer.nvim' }
    -- Core
    use {
        "nvim-lua/plenary.nvim",
        module = "plenary",
    }
    use {
        'folke/which-key.nvim',
        event = "BufWinEnter",
        config = function()
            require('which-key').setup({
                ignore_missing = true,
            })
            require("which-key").register(
                QConfig.which_key.normal_mode,
                {
                    mode = "n",
                    prefix = "<leader>",
                    silent = false,
                }
            )
        end
    }
    use {
        "qgymib/luabuild.nvim",
        requires = {
            {
                "qgymib/luabuild-addons.nvim",
                opt = true,
            }
        },
        after = "plenary.nvim",
        module = "luabuild",
        opt = true,
    }
    -- UI
    use {
        'navarasu/onedark.nvim',
        event = "BufEnter",
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
            require("bufferline").setup({
                options = {
                    right_mouse_command = "vertical sbuffer %d",
                },
            })
        end
    }
    use {
        'shadmansaleh/lualine.nvim',
        after = 'nvim-web-devicons',
        config = function()
            require('lualine').setup()
        end
    }
    -- telescope
    use {
        "nvim-telescope/telescope-fzf-native.nvim",
        run = function(plugin)
            vim.cmd[[packadd luabuild-addons.nvim]]
            require("luabuild-addons").make.telescope_fzf_native(plugin)
        end,
        opt = true,
    }
    use {
        'nvim-telescope/telescope.nvim',
        after = { "plenary.nvim" },
        module = "telescope",
        cmd = "Telescope",
        config = function()
            require('telescope').setup()

            -- telescope-fzf-native.nvim
            vim.cmd[[packadd telescope-fzf-native.nvim]]
            require('telescope').load_extension('fzf')
            -- project.nvim
            require('telescope').load_extension('projects')
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
                    -- Enable completion triggered by <c-x><c-o>
                    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
                    -- Register shortcut
                    require("which-key").register(
                        QConfig.which_key.lsp_mode,
                        {
                            prefix = "<leader>",
                            buffer = bufnr,
                        }
                    )
                end

                -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
                server:setup({
                    on_attach = on_attach_callback,
                    capabilities = require("cmp_nvim_lsp").update_capabilities(
                        vim.lsp.protocol.make_client_capabilities()
                    )
                })
                vim.cmd [[do User LspAttachBuffers]]
            end)
        end
    }
    use {
        "simrat39/symbols-outline.nvim",
        cmd = {
            "SymbolsOutline",
            "SymbolsOutlineOpen",
            "SymbolsOutlineClose",
        },
    }
    -- Auto completion
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            {
                "onsails/lspkind-nvim",
                module = "lspkind",
                event = "InsertEnter",
            },
            {
                'rafamadriz/friendly-snippets',
                after = "lspkind-nvim",
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
        after = 'lspkind-nvim',
        config = function()
            local cmp = require('cmp')
            cmp.setup {
                completion = {
                    keyword_length = 2,
                },
                formatting = {
                    format = require("lspkind").cmp_format({
                        with_text = true,
                        menu = ({
                            nvim_lsp = "[LSP]",
                            luasnip = "[SNIP]",
                            buffer = "[BUF]",
                            nvim_lua = "[LUA]",
                            path = "[PATH]"
                        })
                    })
                },
                mapping = {
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.close(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
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
            vim.g.nvim_tree_respect_buf_cwd = 1
            require('nvim-tree').setup {
                ignore_ft_on_setup = { "dashboard" },
                update_cwd = true,
                update_focused_file = {
                    enable = true,
                    update_cwd = true
                },
            }
        end
    }
    use {
        "ahmedkhalf/project.nvim",
        config = function()
            require("project_nvim").setup()
        end,
        event = "VimEnter",
    }
    use {
        "akinsho/toggleterm.nvim",
        cmd = { "ToggleTerm", "ToggleTermOpenAll", "ToggleTermCloseAll", "TermExec" },
        config = function()
            require("toggleterm").setup()
        end
    }
end,
config = {
    display = {
        open_fn = function()
            return require('packer.util').float({ border = 'single' })
        end
    },
    max_jobs = 4,
}
})
