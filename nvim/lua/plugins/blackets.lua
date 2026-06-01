vim.pack.add({
    { src = "https://github.com/shellRaining/hlchunk.nvim" }
})

local opts = {
    chunk = {
        enable = true,
        style = {
            { fg = "#a08dbc" },
            { fg = "#a21f60" },
        },
        chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = "─",
        },
        duration = 80,
        delay = 10,
    },
    indent = {
        enable = true
    },
    line_num = {
        enable = false
    },
    blank = {
        enable = false,
    },
}
require("hlchunk").setup(opts)
