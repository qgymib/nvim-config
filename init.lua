-- Config pre-setup
QConfig = {}
QConfig.fn = {}
QConfig.plugin = {}

--! @brief Goto the beginning of first non-whitespace character in line
QConfig.fn.GoToLineBegin = function()
    local x = vim.fn.col('.')
    vim.cmd[[execute "normal ^"]]
    if x == vim.fn.col('.') then
        vim.cmd[[execute "normal 0"]]
    end
end

--! @brief Check if a file is exist
--! @param[in] name The path of file
--! @return         bool
QConfig.fn.FileExists = function(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

QConfig.plugin.material = {}
QConfig.plugin.material.config = function()
    vim.cmd[[colorscheme material]]
end

QConfig.plugin.nvim_lspconfig = {}
QConfig.plugin.nvim_lspconfig.config = function()
end

QConfig.plugin.nvim_lsp_installer = {}
QConfig.plugin.nvim_lsp_installer.sumneko_lua = function()
    local opts = {}

    local runtime_path = vim.split(package.path, ';')
    table.insert(runtime_path, "lua/?.lua")
    table.insert(runtime_path, "lua/?/init.lua")

    opts.settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
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
QConfig.plugin.nvim_lsp_installer.config = function()
    local lsp_installer = require("nvim-lsp-installer")

    lsp_installer.on_server_ready(function(server)
        local opts = {}
        -- Add additional capabilities supported by nvim-cmp
        opts.capabilities = require('cmp_nvim_lsp').update_capabilities(
            vim.lsp.protocol.make_client_capabilities())
        -- sumneko_lua configuration
        if server.name == "sumneko_lua" then
            opts = vim.tbl_deep_extend("force", opts, QConfig.plugin.nvim_lsp_installer.sumneko_lua())
        end
        server:setup(opts)
    end)
end

QConfig.plugin.nvim_treesitter = {}
QConfig.plugin.nvim_treesitter.config = function()
    require('nvim-treesitter.configs').setup({
        ensure_installed = "lua",
        highlight = {
            enable = true,
        }
    })
end

QConfig.plugin.indent_blankline = {}
QConfig.plugin.indent_blankline.config = function()
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

QConfig.plugin.nvim_autopairs = {}
QConfig.plugin.nvim_autopairs.config = function()
    require('nvim-autopairs').setup{}
end

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

QConfig.plugins = function(use)
    use 'wbthomason/packer.nvim'
    use {
        'marko-cerovac/material.nvim',
        config = QConfig.plugin.material.config
    }
    use {
        'glepnir/dashboard-nvim',
        config = QConfig.plugin.dashboard_nvim.config
    }
    use {
        'lukas-reineke/indent-blankline.nvim',
        config = QConfig.plugin.indent_blankline.config
    }
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = QConfig.plugin.nvim_treesitter.config
    }
    use {
        'neovim/nvim-lspconfig',
        config = QConfig.plugin.nvim_lspconfig.config
    }
    use {
        'williamboman/nvim-lsp-installer',
        config = QConfig.plugin.nvim_lsp_installer.config
    }
    use {
        'windwp/nvim-autopairs',
        config = QConfig.plugin.nvim_autopairs.config
    }
    use { 'onsails/lspkind-nvim' }
    use { 'hrsh7th/nvim-cmp' }
    use { 'hrsh7th/cmp-nvim-lsp' }
    use { 'saadparwaiz1/cmp_luasnip' }
    use { 'L3MON4D3/LuaSnip' }
    use { 'hrsh7th/cmp-buffer' }
end

-- Setup plugins
require('packer').startup({
    QConfig.plugins,
    config = {
        display = {
            open_fn = function()
                return require('packer.util').float({ border = 'single' })
            end
        },
        max_jobs = 3,
    }
})

local function setup_auto_completion()
    -- Set completeopt to have a better completion experience
    vim.o.completeopt = 'menuone,noselect'

    -- luasnip setup
    local luasnip = require 'luasnip'
    local lspkind = require('lspkind')

    -- nvim-cmp setup
    local cmp = require 'cmp'
    cmp.setup {
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
                with_text = false, -- do not show text alongside icons
                maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            })
        }
    }

    -- If you want insert `(` after select function or method item
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))
end
setup_auto_completion()

-- Basic setup
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

    vim.cmd[[au FocusGained,BufEnter * :silent! !]]

    -- key map
    vim.api.nvim_set_keymap('n', "<Home>", [[<cmd>lua QConfig.fn.GoToLineBegin()<cr>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('i', "<Home>", [[<cmd>lua QConfig.fn.GoToLineBegin()<cr>]], { noremap = true, silent = true })
end
setup_basic_nvim_options()

