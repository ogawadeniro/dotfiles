-- アイコン定数
local ICON_DIR = " 󰉋 "       -- 無名バッファ
local ICON_TERM = "  "      -- ターミナル
local ICON_FILE = "  "      -- フォールバック
local ICON_CURRENT = "▶"     -- カレントバッファの指標
local ICON_MODIFIED = " "   -- 変更あり
-- extmark 用の名前空間
local ICON_NS = vim.api.nvim_create_namespace("bufctl_icons")

local M = {}
M.__index = M

-- 新しいインスタンスを作成
function M.new()
    local self = setmetatable({}, M)
    self.bufctl_bufnr = vim.g.bufctl_bufnr
    self.bufctl_winid = vim.g.bufctl_winid
    self.pre_winid = vim.fn.win_getid()
    self.buflines = {}
    self.bufinfos = {}
    self.longest_line = 0
    return self
end

-- BufCtl を開く
function M:open()
    self:update_bufinfo()

    if #self.buflines < 1 then
        vim.notify("表示できるバッファがないよ", vim.log.levels.WARN, { title = "BufCtl" })
        return
    end

    local width = self.longest_line + 2
    local height = #self.buflines
    local config = {
        window = {
            width     = width,
            height    = height,
            col       = 0,
            row       = vim.opt.lines:get() - 2,
            border    = 'rounded',
            focusable = true,
            style     = 'minimal',
            relative  = 'editor',
            anchor    = 'SW',
        },
        color  = "NormalFloat"
    }
    self:init_ui(config)
    self:write_lines(0, -1, self.buflines)
    self:apply_icon_highlights()
    self:init_keymap()
    self:hide_cursor()

    -- カーソルを行頭に固定
    vim.api.nvim_create_augroup('bufctl', {})
    vim.api.nvim_create_autocmd('CursorMoved', {
        group = 'bufctl',
        callback = function()
            vim.cmd("noautocmd normal! 0")
        end,
        buffer = self.bufctl_bufnr,
    })
end

-- バッファ一覧を取得し行データを構築
function M:update_bufinfo()
    local buf_infos = vim.fn.getbufinfo({ buflisted = 1 })

    self.buflines = {}
    self.bufinfos = {}
    self.longest_line = 0

    for _, bufinfo in ipairs(buf_infos) do
        local raw_name = vim.fs.basename(bufinfo.name)
        if raw_name == "" then
            raw_name = "No Name"
        end

        local is_term = string.match(bufinfo.name, '^term://') ~= nil
        local is_change = bufinfo.changed == 1
        local is_current = (bufinfo.windows ~= nil) and (bufinfo.windows[1] == self.pre_winid)

        -- アイコンと devicon ハイライトグループを決定
        local icon, icon_hl
        if is_term then
            icon = ICON_TERM
        elseif raw_name == "No Name" then
            icon = ICON_DIR
        else
            local ext = vim.fn.fnamemodify(raw_name, ":e")
            local ok, devicons = pcall(require, "nvim-web-devicons")
            if ok then
                local hl
                icon, hl = devicons.get_icon(raw_name, ext)
                icon_hl = hl
            end
            icon = icon or ICON_FILE
        end

        local prefix = is_current and (ICON_CURRENT .. " ") or "  "
        local suffix = is_change and ICON_MODIFIED or ""

        local bufline = prefix .. icon .. " " .. raw_name .. suffix
        if self.longest_line < #bufline then
            self.longest_line = #bufline
        end

        table.insert(self.buflines, bufline)
        table.insert(self.bufinfos, {
            bufnr = bufinfo.bufnr,
            bufname = raw_name,
            is_current = is_current,
            is_change = is_change,
            is_term = is_term,
            icon = icon,
            icon_hl = icon_hl,
        })
    end
end

-- 行を再描画 (削除後に呼ばれる)
function M:redraw_bufline()
    self:write_lines(0, -1, self.buflines)
    self:apply_icon_highlights()

    local win_height = #self.buflines
    if win_height < 1 then
        self:close_all_window()
        return
    end
    local winconfig = {
        height = win_height,
        width = self.longest_line + 2,
    }
    vim.api.nvim_win_set_config(self.bufctl_winid, winconfig)
    vim.api.nvim_set_option_value('signcolumn', 'no', { win = self.bufctl_winid })
end

-- UI の初期化 (ウィンドウ作成とハイライト設定)
function M:init_ui(config)
    local is_shown = (#vim.fn.win_findbuf(self.bufctl_bufnr) > 0)
    local is_current = (vim.fn.bufnr() == self.bufctl_bufnr)
    if is_shown and is_current then
        self:close_all_window()
        return
    elseif is_shown then
        vim.fn.win_gotoid(self.bufctl_winid)
    else
        local win_main = self:init_window(config.window)
        self.bufctl_bufnr = win_main.bufnr
        self.bufctl_winid = win_main.winid
        vim.g.bufctl_bufnr = win_main.bufnr
        vim.g.bufctl_winid = win_main.winid
    end
    self:init_highlight()
end

-- matchadd とハイライトグループの定義
function M:init_highlight()
    vim.fn.clearmatches(self.bufctl_winid)
    vim.fn.matchadd('BufCtlNoFile', '\\v(No Name|Term: .+)$', 11, 5)
    vim.fn.matchadd('BufCtlIndicator', '\\v^▶', 10, 7)
    vim.fn.matchadd('BufCtlModified', '\\v', 10, 8)
    vim.cmd("hi! def link BufCtlNoFile Statement")
    vim.cmd("hi BufCtlIndicator guifg=#89b4fa gui=bold")
    vim.cmd("hi BufCtlModified guifg=#f9e2af")
    vim.cmd("hi BufCtlTermName guifg=#a6e3a1")
end

-- devicon とファイル名を extmark でハイライト
function M:apply_icon_highlights()
    vim.api.nvim_buf_clear_namespace(self.bufctl_bufnr, ICON_NS, 0, -1)

    for i, bufinfo in ipairs(self.bufinfos) do
        local prefix = bufinfo.is_current and (ICON_CURRENT .. " ") or "  "
        local prefix_byte = #prefix
        local icon_byte = #bufinfo.icon

        local name_start = prefix_byte + icon_byte + 1
        local name_end = name_start + #bufinfo.bufname

        -- ファイル名: 通常は Normal、ターミナルは緑
        local name_hl = bufinfo.is_term and 'BufCtlTermName' or 'Normal'
        vim.api.nvim_buf_set_extmark(self.bufctl_bufnr, ICON_NS, i - 1, name_start, {
            end_col = name_end,
            hl_group = name_hl,
            priority = 100,
        })

        -- アイコン: devicon が返すハイライトグループで着色
        if bufinfo.icon_hl then
            vim.api.nvim_buf_set_extmark(self.bufctl_bufnr, ICON_NS, i - 1, prefix_byte, {
                end_col = prefix_byte + icon_byte,
                hl_group = bufinfo.icon_hl,
                priority = 200,
            })
        end
    end
end

-- カーソル非表示 + cursorline 有効化
function M:hide_cursor()
    self.orig_guicursor = vim.opt.guicursor:get()
    self.orig_winhighlight = vim.wo[self.bufctl_winid].winhighlight
    vim.opt.guicursor = "a:ver1"
    vim.wo[self.bufctl_winid].winhighlight = "Cursor:NormalFloat"
    vim.wo[self.bufctl_winid].cursorline = true
end

-- ウィンドウを作成または既存を再利用
function M:init_window(win_config)
    local bufnr = self.bufctl_bufnr
    if bufnr == nil then
        bufnr = vim.api.nvim_create_buf(false, true)
    end

    if (self.bufctl_winid == nil) or (#vim.fn.win_findbuf(bufnr) < 1) then
        local winid = vim.api.nvim_open_win(bufnr, win_config.focusable, win_config)
        return { bufnr = bufnr, winid = winid }
    else
        return { bufnr = bufnr, winid = self.bufctl_winid }
    end
end

function M:close_all_window()
    self:close_window()
end

-- ウィンドウを閉じ、guicursor を復元
function M:close_window()
    if (self.bufctl_winid ~= nil) and (#vim.fn.win_findbuf(self.bufctl_bufnr) > 0) then
        vim.api.nvim_win_close(self.bufctl_winid, true)
    end
    if self.orig_guicursor then
        vim.opt.guicursor = self.orig_guicursor
    end
end

-- バッファに行を書き込む
function M:write_lines(startl, endl, lines)
    vim.api.nvim_set_option_value('modifiable', true, { buf = self.bufctl_bufnr })
    vim.api.nvim_set_option_value('readonly', false, { buf = self.bufctl_bufnr })
    vim.api.nvim_buf_set_lines(self.bufctl_bufnr, startl, endl, false, lines)
    vim.api.nvim_set_option_value('modifiable', false, { buf = self.bufctl_bufnr })
    vim.api.nvim_set_option_value('readonly', true, { buf = self.bufctl_bufnr })
    vim.cmd("redraw")
end

-- キーマップの設定
function M:init_keymap()
    vim.api.nvim_buf_set_keymap(self.bufctl_bufnr, "n", "<Enter>", "", {
        noremap = true,
        callback = function() self:enter_buffer() end,
    })
    vim.api.nvim_buf_set_keymap(self.bufctl_bufnr, "n", "D", "", {
        noremap = true,
        callback = function() self:delete_buf() end,
    })
    vim.api.nvim_buf_set_keymap(self.bufctl_bufnr, 'n', 'q', '', {
        callback = function() self:close_all_window() end,
    })
end

-- 選択したバッファに移動
function M:enter_buffer()
    local linenr = vim.fn.line(".")
    local selected_bufinfo = self.bufinfos[linenr]

    if selected_bufinfo == nil then
        vim.notify("バッファ情報が見つからなかったよ", vim.log.levels.WARN, { title = "BufCtl" })
        return
    end

    self:close_all_window()
    vim.fn.win_gotoid(self.pre_winid)
    vim.cmd("b " .. selected_bufinfo.bufnr)
    vim.notify(selected_bufinfo.bufname .. " に移動したよ", vim.log.levels.INFO, { title = "BufCtl" })
end

-- バッファを削除
function M:delete_buf()
    local linenr = vim.fn.line(".")
    local bufinfo = self.bufinfos[linenr]

    if bufinfo == nil then
        vim.notify("バッファ情報が見つからなかったよ", vim.log.levels.WARN, { title = "BufCtl" })
        return
    end
    if bufinfo.is_current then
        vim.notify("今のバッファは削除できないよ", vim.log.levels.ERROR, { title = "BufCtl" })
        return
    end
    if bufinfo.is_term then
        vim.notify("ターミナルバッファは削除できないよ", vim.log.levels.ERROR, { title = "BufCtl" })
        return
    end
    if bufinfo.is_change and not self:is_confirmed("バッファが変更されてるけど削除していい？") then
        vim.notify("削除をキャンセルしたよ", vim.log.levels.INFO, { title = "BufCtl" })
        return
    end

    vim.cmd("bd! " .. bufinfo.bufnr)
    self:update_bufinfo()
    self:redraw_bufline()
end

-- 確認ダイアログ (y 以外は false)
function M:is_confirmed(msg)
    local inputstr = require('util.helper').highlightInput(
        vim.log.levels.WARN,
        "[BufCtl] " .. msg .. " y を入力して続行 > ",
        ""
    )
    return inputstr == 'y'
end

-- leader + b で BufCtl を起動
vim.api.nvim_set_keymap("n", '<leader>b', '', {
    noremap = true,
    callback = function()
        local bufctl = M.new()
        bufctl:open()
    end,
    desc = 'BufCtl を起動',
})

return M
