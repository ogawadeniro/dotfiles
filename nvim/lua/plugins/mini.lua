vim.pack.add({
    { src = "https://github.com/nvim-mini/mini.nvim" },
})
-- ペア文字入力
-- require('mini.pairs').setup()
-- 囲む系
require("mini.surround").setup()

--[[
-- 通知
local mini_notify = require('mini.notify')
local win_config = function()
    --通知を右下に表示する
    local has_statusline = vim.o.laststatus > 0
    local pad = vim.o.cmdheight + (has_statusline and 1 or 0)
    return { anchor = 'SE', col = vim.o.columns, row = vim.o.lines - pad }
end

local icons = require("assets.icons")
local fmt_config = function(notif)
    local icon_list = {
        ERROR = icons.status.error.icon,
        WARN = icons.status.warn.icon,
        INFO = icons.status.info.icon,
        DEBUG = icons.operation.debug.icon,
        OFF = "[OFF]",
        TRACE = "[TRACE]",
    }
    local icon = icon_list[notif.level]
    local ts_add = vim.fn.strftime("%T", math.floor(notif.ts_add))
    local title = ""
    if notif.data.response then
        title = " " .. notif.data.response.value.title .. " "
    end
    local src = (("[" .. notif.data.source).. "]" or "[unknown]")
    local header = icon .. ts_add .. title .. src .. " "

    local body = "  " .. notif.msg .. " "
    local fmt = header .. "\n" .. body
    return fmt
    -- return mini_notify.default_format(notif)
end
mini_notify.setup({
    content = {
        format = fmt_config,
    },
    -- Floating window config
    window = {
        config = win_config,
    }
})

vim.notify = mini_notify.make_notify({})

vim.api.nvim_create_user_command('Notify', function()
    local winid = vim.api.nvim_open_win(0, false, { split = "below", height = math.floor(vim.o.lines / 4) })
    vim.fn.win_gotoid(winid)
    mini_notify.show_history()
    vim.api.nvim_buf_set_keymap(0, "n", "q", "<Cmd>q<CR>", {})
end, { desc = 'mini notifyの履歴を表示' })
--]]
