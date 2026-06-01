vim.pack.add({
    { src = "https://github.com/ray-x/lsp_signature.nvim" }
})

local opts = {
    bind = true,
    handler_opts = {
        border = "rounded",
    },
    hint_prefix = "🕊️ ",
}
require('lsp_signature').setup(opts)

-- attach lsp_signature on buffer enter.
-- vim.api.nvim_create_autocmd({ "BufEnter" }, {
-- pattern = { "*.lua", "*.c", "*.py" },
-- callback = function()
-- require('lsp_signature').on_attach()
-- end,
-- })
