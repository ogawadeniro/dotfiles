vim.pack.add({
    { src = "https://github.com/rcarriga/nvim-notify" }
})

local icons = require("assets.icons")
local notify = require("notify")
notify.setup({
    icons = {
        DEBUG = "",
        ERROR = icons.status.error.icon,
        INFO = icons.status.info.icon,
        TRACE = "✎",
        WARN = icons.status.warn.icon,
    },
    --stages = "fade",
    top_down = false,
    background_colour = "#000000", -- 背景透過したときにこれがないと怒られる
})

vim.notify = require("notify")
