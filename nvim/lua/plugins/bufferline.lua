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
