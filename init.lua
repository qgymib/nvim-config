QConfig = {}
QConfig.fn = {}
QConfig.plugin = {}

vim.cmd(
[[
call plug#begin()

Plug 'nvim-lua/plenary.nvim'
Plug 'marko-cerovac/material.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'nvim-lualine/lualine.nvim'
Plug 'folke/which-key.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'glepnir/dashboard-nvim'
Plug 'windwp/nvim-autopairs'
Plug 'folke/which-key.nvim'

" Fuzzy finder
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'hrsh7th/nvim-cmp'
Plug 'onsails/lspkind-nvim'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'
Plug 'hrsh7th/cmp-buffer'

call plug#end()
]])

--- @brief Go to the beginning of line
QConfig.fn.GoToLineBegin = function ()
    local x = vim.fn.col('.')
    vim.cmd[[execute "normal ^"]]
    if x == vim.fn.col('.') then
        vim.cmd[[execute "normal 0"]]
    end
end

-- vim-plug
QConfig.plugin.vim_plug = {}
QConfig.plugin.vim_plug.config = function()
    vim.g.plug_threads = 4
end
QConfig.plugin.vim_plug.config()

-- material.nvim
QConfig.plugin.material = {}
QConfig.plugin.material.config = function()
    vim.cmd[[colorscheme material]]
end
QConfig.plugin.material.config()

-- indent-blankline.nvim
QConfig.plugin.indent_blankline = {}
QConfig.plugin.indent_blankline.config = function()
    require('indent_blankline').setup {
        filetype_exclude = {
           "help",
           "terminal",
           "dashboard",
           "packer",
           "lsp-installer",
           "lspinfo",
           "TelescopePrompt",
           "TelescopeResults",
        },
        buftype_exclude = { "terminal" },
        show_trailing_blankline_indent = false,
        show_first_indent_level = false,
    }
end
QConfig.plugin.indent_blankline.config()

-- dashboard-nvim
QConfig.plugin.dashboard_nvim = {}
QConfig.plugin.dashboard_nvim.config = function()
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
        e = {
            description = { "  Configuration      " },
            command = ":e " .. vim.fn.stdpath('config') .. "/init.lua"
        },
    }
    vim.g.dashboard_custom_footer = {
        "",
    }
end
QConfig.plugin.dashboard_nvim.config()

-- nvim-autopairs
QConfig.plugin.nvim_autopairs = {}
QConfig.plugin.nvim_autopairs.config = function()
    require('nvim-autopairs').setup{}
end
QConfig.plugin.nvim_autopairs.config()

-- nvim-treesitter
QConfig.plugin.nvim_treesitter = {}
QConfig.plugin.nvim_treesitter.config = function()
    require('nvim-treesitter.configs').setup({
        ensure_installed = "lua",
        highlight = {
            enable = true,
        }
    })
end
QConfig.plugin.nvim_treesitter.config()

-- lualine.nvim
QConfig.plugin.lualine = {}
QConfig.plugin.lualine.config = function()
    require('lualine').setup()
end
QConfig.plugin.lualine.config()

-- telescope.nvim
QConfig.plugin.telescop = {}
QConfig.plugin.telescop.config = function()
    local telescope = require('telescope')
    telescope.setup({
        extensions = {
            fzf = {
                fuzzy = true,                       -- false will only do exact matching
                override_generic_sorter = true,     -- override the generic sorter
                override_file_sorter = true,        -- override the file sorter
                case_mode = "smart_case",           -- or "ignore_case" or "respect_case"
                                                    -- the default case_mode is "smart_case"
            }
        }
    })
    telescope.load_extension('fzf')
end

-- nvim-lsp-installer
QConfig.plugin.nvim_lsp_installer = {}
QConfig.plugin.nvim_lsp_installer.sumneko_lua = function()
    local opts = {}

    local runtime_path = vim.split(package.path, ';')
    table.insert(runtime_path, "lua/?.lua")
    table.insert(runtime_path, "lua/?/init.lua")

    opts.settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = runtime_path,
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    }

    return opts
end
QConfig.plugin.nvim_lsp_installer.update_options = function(server, opts)
    if server.name == "sumneko_lua" then
        opts = vim.tbl_deep_extend("force", opts,
            QConfig.plugin.nvim_lsp_installer.sumneko_lua())
    end
    return opts
end
QConfig.plugin.nvim_lsp_installer.config = function()
    local lsp_installer = require("nvim-lsp-installer")

    lsp_installer.on_server_ready(function(server)
        local opts = {}
        -- Add additional capabilities supported by nvim-cmp
        opts.capabilities = require('cmp_nvim_lsp').update_capabilities(
            vim.lsp.protocol.make_client_capabilities())
        -- sumneko_lua configuration
        opts = QConfig.plugin.nvim_lsp_installer.update_options(server, opts)
        server:setup(opts)
    end)
end
QConfig.plugin.nvim_lsp_installer.config()

-- nvim-cmp
QConfig.plugin.nvim_cmp = {}
QConfig.plugin.nvim_cmp.config = function()
    -- Set completeopt to have a better completion experience
    vim.o.completeopt = 'menuone,noselect'

    -- luasnip setup
    local luasnip = require('luasnip')
    local lspkind = require('lspkind')

    -- nvim-cmp setup
    local cmp = require('cmp')
    cmp.setup({
        snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body)
            end,
        },
        mapping = {
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.close(),
            ['<CR>'] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
            },
            ['<Tab>'] = function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end,
            ['<S-Tab>'] = function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end,
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
        }, {
            { name = 'buffer' },
        }),
        formatting = {
            format = lspkind.cmp_format({
                -- do not show text alongside icons
                with_text = true,
                -- prevent the popup from showing more than provided characters
                -- (e.g 50 will not show more than 50 characters)
                maxwidth = 50,
            })
        }
    })

    -- If you want insert `(` after select function or method item
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
end
QConfig.plugin.nvim_cmp.config()

-- nvim-lspconfig
QConfig.plugin.nvim_lspconfig = {}
QConfig.plugin.nvim_lspconfig.config = function()
    -- TextEdit might fail if hidden is not set.
    vim.o.hidden = true
    -- Some servers have issues with backup files, see #649.
    vim.cmd[[set nobackup]]
    vim.cmd[[set nowritebackup]]
    -- Give more space for displaying messages.
    vim.o.cmdheight = 2
    -- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
    -- delays and poor user experience.
    vim.o.updatetime = 300
    -- Don't pass messages to |ins-completion-menu|.
    vim.cmd[[set shortmess+=c]]
    -- Always show the signcolumn, otherwise it would shift the text each time
    -- diagnostics appear/become resolved.
    vim.cmd[[set signcolumn=number]]
end
QConfig.plugin.nvim_lspconfig.config()

-- nvim-tree
QConfig.plugin.nvim_tree = {}
QConfig.plugin.nvim_tree.config = function()
    require('nvim-tree').setup()
end
QConfig.plugin.nvim_tree.config()

-- which-key.nvim
QConfig.plugin.which_key = {}
QConfig.plugin.which_key.normal_mode = {
    ["<Home>"] = {
        "<cmd>lua QConfig.fn.GoToLineBegin()<cr>",
        "Goto begin of line"
    },
    ["<F12>"] = {
        "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>",
        "Jump to definitions"
    },
    ["<leader>"] = {
        b = {
            name = "+buffer",
            l = {
                "<cmd>Telescope buffers<cr>",
                "List buffers"
            },
        },
        f = {
            name = "+file",
            b = {
                "<cmd>NvimTreeToggle<cr>",
                "browser (Toggle)"
            },
        },
        s = {
            name = "+search",
            f = {
                "<cmd>Telescope find_files<cr>",
                "File name"
            },
            G = {
                "<cmd>Telescope grep_string<cr>",
                "<cursor> in workspace"
            },
            S = {
                "<cmd>Telescope live_grep<cr>",
                "String in workspace"
            }
        }
    },
}
QConfig.plugin.which_key.insert_mode = {
    ["<Home>"] = QConfig.plugin.which_key.normal_mode["<Home>"],
}
QConfig.plugin.which_key.config = function()
    local which_key = require('which-key')
    which_key.setup({
        ignore_missing = true,
    })
    which_key.register(
        QConfig.plugin.which_key.normal_mode,
        {
            mode = "n",
            silent = true,
        }
    )
    which_key.register(
        QConfig.plugin.which_key.insert_mode,
        {
            mode = "i",
            silent = true,
        }
    )
end
QConfig.plugin.which_key.config()

-- Basic setup
local function setup_basic_nvim_options()
    -- use <space> as leader key
    vim.g.mapleader = " "
    vim.opt.timeoutlen = 400
    vim.opt.termguicolors = true
    vim.opt.title = true
    vim.opt.clipboard = "unnamedplus"
    vim.opt.cul = true
    -- disable tilde on end of buffer: https://github.com/neovim/neovim/pull/8546#issuecomment-643643758
    vim.opt.fillchars = { eob = " " }
    vim.opt.ignorecase = true
    vim.opt.mouse = "a"
    -- Numbers
    vim.opt.number = true
    vim.opt.ruler = false
    -- Don't show any numbers inside terminals
    vim.cmd[[au TermOpen term://* setlocal nonumber norelativenumber | setfiletype terminal]]
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
    vim.o.scrolloff = 3
    vim.cmd[[au FocusGained,BufEnter * :silent! !]]
end
setup_basic_nvim_options()

