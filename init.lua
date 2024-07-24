require("config.lazy")
vim.env.OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

local null_ls = require("null-ls")

-- Create an augroup for LSP formatting
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- Function to check if null-ls is attached and register the formatters
local function lsp_formatting(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            return client.name == "null-ls"
        end,
        bufnr = bufnr,
    })
end

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.clang_format,
        null_ls.builtins.formatting.black,
        -- Add more formatters or linters here
    },
    on_attach = function(client, bufnr)
        if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    lsp_formatting(bufnr)
                end,
            })
            print("null-ls attached to buffer " .. bufnr)
        end
    end,
})

-- Create a command for manual formatting
vim.api.nvim_create_user_command('Format', function()
    vim.lsp.buf.format({
        filter = function(client)
            return client.name == "null-ls"
        end,
        async = true,
    })
end, {})

-- Keybinding for formatting
vim.api.nvim_set_keymap('n', '<leader>f', ':Format<CR>', { noremap = true, silent = true })

-- Debugging information to verify null-ls setup
vim.cmd([[
  augroup FormatAutogroup
    autocmd!
    autocmd BufWritePre *.cpp,*.hpp,*.cc,*.c,*.h,*.py lua print('LSP: Formatting buffer with null-ls') vim.lsp.buf.format({ async = true })
  augroup END
]])

-- Show line numbers always
vim.opt.number = true

-- 120 line length
vim.opt.colorcolumn = "120"
vim.cmd [[highlight ColorColumn ctermbg=0 guibg=black]]


-- nvim-tree recommendations
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true


-- Ctrl n
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Set tab width for Python files to 2 spaces
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.opt_local.expandtab = true
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2
    end,
})

