vim.pack.add({
    { src = "https://github.com/akinsho/bufferline.nvim" },
})
require("bufferline").setup({
    options = {
        indicator = {
            style = "icon"
        },
        diagnostics = "nvim_lsp",

        offsets = {
            {
                filetype = "NvimTree",
                text = function()
                    return vim.fn.getcwd()
                end,
                highlight = "Directory",
                text_align = "left",
                separator = false,
            }
        },
        show_buffer_close_icons = false,
        separator_style = "thin"

    }
})

vim.api.nvim_set_hl(0, "BufferLineFill", { link = "StatusLineNC" })
-- vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { link = "StatusLineNC" })     --選択中のバッファ
-- vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { link = "StatusLineNC" })      --他バッファ
--
-- vim.api.nvim_set_hl(0, "BufferLineDevIconLuaInactive", { link = "StatusLineNC" }) --他バッファ
-- vim.api.nvim_set_hl(0, "BufferLineDevIconLuaSelected", { link = "StatusLineNC" }) --他バッファ
