vim.pack.add({
    { src = "https://github.com/stevearc/dressing.nvim" },      -- input系のウィンドウをいい感じにする
    { src = "https://github.com/rachartier/tiny-cmdline.nvim" } -- vimのcmdlineをいい感じにする
})
require("tiny-cmdline").setup({
    width = { value = "60%" },
    position = {
        y = "75%",
        x = "50%"
    },
    menu_col_offset = 1,
    title = {
        enabled = true,
        pos = "left", -- "left" | "center" | "right"
    },
})
