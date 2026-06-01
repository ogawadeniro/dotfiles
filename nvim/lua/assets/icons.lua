vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-web-devicons" }
})

-- deviconsをオーバーライド
require("nvim-web-devicons").setup({
    override_by_extension = {
        ["ghostty"] = {
            icon = "",
            color = "#d0d0d0",
            name = "Ghostty",
        },
    },
})

return {
    status = {
        ok = { icon = "󰗠 " }, -- nf-md-check_circle
        no = { icon = " " },
        error = { icon = " ", color = "" }, -- 󰯸   nf_oct_x_circle_fill
        warn = { icon = " ", color = "" }, -- 󰰮
        info = { icon = "󰰄 ", color = "" }, -- nf-md-alpha_i_circle
    },
    operation = {
        add = { icon = "󰐗 " }, -- nf-md-plus_circle
        hint = { icon = "󰠠 " },
        debug = { icon = " " },
    },
    slant = {
        fill_r = "◣",
        fill_l = "◢",
        out_r = "╲",
        out_l = "╱",
    },
    curv = {
        l = "",
        r = ""
    },
    bar = {
        " ", --(0/8)
        "▏", --(1/8)
        "▎", --(2/8)
        "▍", --(3/8)
        "▌", --(4/8)
        "▋", --(5/8)
        "▊", --(6/8)
        "▉", --(7/8)
        "█", --(8/8)
    },
    git = {
        unstaged = { icon = "󰰐" },
        staged = { icon = "󰯬" },
        -- unmerged ={icon = ""},
        -- renamed ={icon = "➜"},
        untracked = { icon = "󰰓" },
        deleted = { icon = "󰯵" },
        ignored = { icon = "󰰄" },
    },
    nwd = require("nvim-web-devicons")
}
