vim.pack.add({
    { src = "https://github.com/petertriho/nvim-scrollbar" },
    { src = "https://github.com/kevinhwang91/nvim-hlslens" }
})

-- event = { "BufRead", "BufNewFile" },
-- スクロールバー有効化
require("scrollbar").setup({
    handle = {
        blend = 0,
    },
    marks = {
        Cursor = {
            text = require("assets.icons").bar[9],
        },
    },
    excluded_buftypes = {
        "terminal",
        "nofile",
        "acwrite",
        "prompt"
    },
    handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true, -- Requires gitsigns
        handle = true,
        search = true,   -- Requires hlslens
        ale = false,     -- Requires ALE
    },
})
-- 検索時にマークを表示する
require("hlslens").setup({})
require("scrollbar.handlers.search").setup()
vim.api.nvim_create_autocmd({ 'CmdlineLeave', "DiffUpdated" }, {
    callback = function()
        require('scrollbar.handlers.search').handler.hide()
    end
})

-- gitの状態を表示
require("scrollbar.handlers.gitsigns").setup()

-- 色設定
local colors = require("assets.palet")
local color_opts = {
    --ハンドル部分のハイライト(画面に表示されている部分を指すスクロールバー)
    { name = "ScrollbarHandle",          bg = colors.mono[4] },
    { name = "ScrollbarSearchHandle",    bg = colors.mono[4] },
    { name = "ScrollbarErrorHandle",     bg = colors.mono[4] },
    { name = "ScrollbarWarnHandle",      bg = colors.mono[4] },
    { name = "ScrollbarInfoHandle",      bg = colors.mono[4] },
    { name = "ScrollbarHintHandle",      bg = colors.mono[4] },
    { name = "ScrollbarMiscHandle",      bg = colors.mono[4] },
    { name = "ScrollbarGitAddHandle",    bg = colors.mono[4] },
    { name = "ScrollbarGitChangeHandle", bg = colors.mono[4] },
    { name = "ScrollbarGitDeleteHandle", bg = colors.mono[4] },

    -- カーソルのハイライト
    { name = "ScrollbarCursor",          fg = colors.mono[1] },
    { name = "ScrollbarCursorHandle",    fg = colors.mono[1] },
}

for i = 1, #color_opts, 1 do
    local color_opt = color_opts[i]
    if color_opt.fg ~= nil then
        vim.cmd("hi!" .. color_opt.name .. " guifg=" .. color_opt.fg)
    end
    if color_opt.bg ~= nil then
        vim.cmd("hi!" .. color_opt.name .. " guibg=" .. color_opt.bg)
    end
end
