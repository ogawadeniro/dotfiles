-- ==============================================================================
-- leaderkey
-- ==============================================================================
vim.g.mapleader = " "


-- ==============================================================================
-- 便利系
-- ==============================================================================
-- 全バッファ再読込
vim.keymap.set("n", "<leader>r", function()
    vim.cmd("bufdo e!")
    vim.notify("全バッファを再読込したよ")
end, { noremap = true, desc = "全バッファ再読込" })

-- ファイル保存
vim.keymap.set("n", "<C-s>", "<CMD>w<CR>", { noremap = true })

-- ブラウザを開く
local function open_browser()
    local line = vim.api.nvim_get_current_line()
    -- reg1: urlの次が空白文字、"、,の時だけ見つかる
    -- local regex_url = "a-zA-Z0-9-_~%.:/#@!&',;=%[%]%(%)%+%*%$%?"
    -- local regex_noturl = "%s\",$"
    -- reg2: 見つかりやすいが厳密でない
    -- local regex_url = "a-zA-Z0-9-_~%./#@!&,=%[%]%+%*%$%?"
    -- local regex_noturl = "%s;:'\",%)"
    local regex_end_of_url = "%s'\",%)"

    -- local url = string.match(line, "(https?://[" .. regex_url .. "]+)[" .. regex_noturl .. "]")
    local url = string.match(line, "(https?://[^" .. regex_end_of_url .. "]+)[" .. regex_end_of_url .. "]")
    if not url then --URL使用可能文字だけで終わる場合
        -- url = string.match(line, "(https?://[" .. regex_url .. "]+)$")
        url = string.match(line, "(https?://[^" .. regex_end_of_url .. "]+)$")
    end
    if not url then
        vim.notify("urlが見つからなかったよ", vim.log.levels.WARN)
        return
    end

    ---@type table<string, string[]> 値は、はじめにコマンド、その後に引数を取るリスト。%sをURLのプレースホルダーとする
    local browser_commands = {
        chrome = { "google-chrome", '"%s"' },
        chrome_stable = { "google-chrome-stable", '"%s"' }
    }
    for browser, command in pairs(browser_commands) do
        local has_browser = vim.fn.executable(command[1])
        if has_browser == 1 then
            local cmd_fmt = table.concat(command, " ")
            local cmd_line = string.format(cmd_fmt, url)
            vim.print(cmd_line)
            pcall(vim.fn.jobstart, cmd_line)
            vim.notify(browser .. "で" .. url .. "を開いたよ")
            return
        end
    end
end
vim.keymap.set("n", "<leader>B", open_browser, { desc = "ブラウザでカーソル行下のリンクを開く" })

-- ==============================================================================
-- ウィンドウ操作系
-- ==============================================================================
-- C-w + 矢印キーでリサイズモードに入る。連打で繰り返しリサイズ可能
vim.g._resize_mode = false
local resize_timer = nil

local function enter_resize_mode()
    vim.g._resize_mode = true
    if resize_timer then pcall(resize_timer.close, resize_timer) end
    resize_timer = vim.defer_fn(function() vim.g._resize_mode = false end, 1500)
end

vim.keymap.set("n", "<C-w><Right>", function()
    enter_resize_mode()
    vim.cmd("vertical resize +1")
end, { desc = "ウィンドウ幅を広げる（連打可）" })
vim.keymap.set("n", "<C-w><Left>", function()
    enter_resize_mode()
    vim.cmd("vertical resize -1")
end, { desc = "ウィンドウ幅を狭める（連打可）" })
vim.keymap.set("n", "<C-w><Up>", function()
    enter_resize_mode()
    vim.cmd("resize +1")
end, { desc = "ウィンドウ高さを広げる（連打可）" })
vim.keymap.set("n", "<C-w><Down>", function()
    enter_resize_mode()
    vim.cmd("resize -1")
end, { desc = "ウィンドウ高さを狭める（連打可）" })

-- リサイズモード中は矢印キー単体でリサイズを繰り返す
local key_move = {
    Right = { resize = "vertical resize +1", desc = "幅を広げる" },
    Left  = { resize = "vertical resize -1", desc = "幅を狭める" },
    Up    = { resize = "resize +1", desc = "高さを広げる" },
    Down  = { resize = "resize -1", desc = "高さを狭める" },
}
for name, opt in pairs(key_move) do
    local feedkey = vim.api.nvim_replace_termcodes("<" .. name .. ">", true, false, true)
    vim.keymap.set("n", "<" .. name .. ">", function()
        if vim.g._resize_mode then
            enter_resize_mode()
            vim.cmd(opt.resize)
        else
            vim.api.nvim_feedkeys(feedkey, "n", false)
        end
    end, { desc = "カーソル移動 / リサイズモード時は" .. opt.desc })
end

-- Esc でリサイズモード解除
vim.keymap.set("n", "<Esc>", function()
    if vim.g._resize_mode then
        vim.g._resize_mode = false
        if resize_timer then pcall(resize_timer.close, resize_timer) end
    end
    vim.cmd("nohl")
end, { desc = "検索ハイライト解除 / リサイズモード解除" })

-- ==============================================================================
-- モード系
-- ==============================================================================
--  ターミナルでジョブモードを抜ける
vim.keymap.set("t", "<C-[>", "<C-\\><C-N>", { noremap = true, desc = "ターミナルのジョブモードを抜ける" })

-- ==============================================================================
-- 編集系
-- ==============================================================================

-- コメントキーマップ
-- ------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "コメントアウト" })
vim.keymap.set("v", "<leader>/", "gc", { remap = true, desc = "コメントアウト" })

-- 囲む系文字の内側に移動
-- ------------------------------------------------------------------------------
local surround_chars = {
    { '"', '"' },
    { "'", "'" },
    { "(", ")" },
    { "[", "]" },
    { "{", "}" },
    { "<", ">" },
    { "%", "%" },
}
for i = 1, #surround_chars do
    local pair = surround_chars[i][1] .. surround_chars[i][2]
    vim.keymap.set({ "i", "c" }, pair, pair .. '<Left>', { noremap = true })
end

-- 行末文字列挿入・行末文字列削除
-- ------------------------------------------------------------------------------
-- ファイルタイプ設定
local ft_eol_str_index = {
    rust = ";",
    markdown = "  ",
    css = ";",
    json = ",",
    jsonc = ",",
}
vim.g.eol_str = nil
-- 行末挿入を有効にするファイルタイプのリストを定義
local filetypes = {}
for ft, _ in pairs(ft_eol_str_index) do
    table.insert(filetypes, ft)
end

-- 行末文字列挿入を有効にするファイルタイプだった場合は、グローバル変数に行末文字列をもたせる
-- 違った場合はグローバル変数をから文字列で再定義
vim.api.nvim_create_autocmd('FileType', {
    -- pattern = { "*" },
    callback = function(e)
        if vim.o.bt ~= "" then return end
        local ft = e.match
        if not vim.tbl_contains(filetypes, ft) then
            return
        end
        local eol_str = ft_eol_str_index[ft]
        if eol_str ~= nil then
            vim.g.eol_str = eol_str
        end
    end
})
-- 行末に文字列を挿入する関数
local function insert_str_at_eol()
    if vim.g.eol_str == "" then return end
    local pos_prev = vim.fn.getpos(".")
    vim.cmd('noautocmd normal! $a' .. vim.g.eol_str .. '')
    vim.fn.setpos(".", pos_prev)
    vim.cmd('noautocmd normal! a')
end
-- 行末の文字列を削除する関数
local function delete_str_at_eol()
    if vim.g.eol_str == "" then return end
    -- == カーソル行の行末文字列を削除(空白文字列に置換)
    local line_nr = vim.api.nvim_win_get_cursor(0)[1]
    local regex_before = vim.g.eol_str .. "$"
    --patter not found エラーを無視
    local _, _ = pcall(vim.api.nvim_exec2, line_nr .. 's/' .. regex_before .. '//', { output = false })
    --置換後に検索ハイライトが出るので消す
    vim.cmd("nohl")
end

-- 行末文字列トグルキーマップ
vim.keymap.set("n", "<leader>;", "", {
    noremap = true,
    -- callback = insert_str_at_eol,
    callback = function()
        local line = vim.api.nvim_get_current_line()
        local match = string.match(line, ".*" .. vim.g.eol_str .. "$")
        if match then
            delete_str_at_eol()
        else
            insert_str_at_eol()
        end
    end,
    desc = "ファイルタイプごとに決まった文字列を行末に挿入"
})
-- -- 行末文字列削除キーマップ
-- vim.keymap.set("n", "<leader>g;", "", {
--     noremap = true,
--     callback = delete_str_at_eol,
--     desc = "ファイルタイプごとに決まった文字列を行末から削除"
-- })

-- ==============================================================================
-- 移動系
-- ==============================================================================
-- かな移動
local move_prefix = { f = "gf", F = "gF", t = "gt", T = "gT" }
local char_maps = {
    { ".", "。" }, { ",", "、" },
    { "a", "あ" }, { "i", "い" }, { "u", "う" }, { "e", "え" }, { "o", "お" },
    { "ka", "か" }, { "ki", "き" }, { "ku", "く" }, { "ke", "け" }, { "ko", "こ" },
    { "ga", "が" }, { "gi", "ぎ" }, { "gu", "ぐ" }, { "ge", "げ" }, { "go", "ご" },
    { "sa", "さ" }, { "si", "し" }, { "su", "す" }, { "se", "せ" }, { "so", "そ" },
    { "za", "ざ" }, { "ji", "し" }, { "zu", "ず" }, { "ze", "ぜ" }, { "zo", "ぞ" },
    { "ta", "た" }, { "ti", "ち" }, { "tu", "つ" }, { "te", "て" }, { "to", "と" },
    { "da", "だ" }, { "di", "ぢ" }, { "du", "づ" }, { "de", "で" }, { "do", "ど" },
    { "na", "な" }, { "ni", "に" }, { "nu", "ぬ" }, { "ne", "ね" }, { "no", "の" },
    { "ha", "は" }, { "hi", "ひ" }, { "hu", "ふ" }, { "he", "へ" }, { "ho", "ほ" },
    { "ba", "ば" }, { "bi", "び" }, { "bu", "ぶ" }, { "be", "べ" }, { "bo", "ぼ" },
    { "pa", "ぱ" }, { "pi", "ぴ" }, { "pu", "ぷ" }, { "pe", "ぺ" }, { "po", "ぽ" },
    { "ma", "ま" }, { "mi", "み" }, { "mu", "む" }, { "me", "め" }, { "mo", "も" },
    { "ya", "や" }, { "yu", "ゆ" }, { "yo", "よ" },
    { "ra", "ら" }, { "ri", "り" }, { "ru", "る" }, { "re", "れ" }, { "ro", "ろ" },
    { "wa", "わ" }, { "wo", "を" },
}
for prefix, map_prefix in pairs(move_prefix) do
    for _, char_map in ipairs(char_maps) do
        vim.keymap.set("n", map_prefix .. char_map[1], prefix .. char_map[2], { noremap = true })
    end
end

-- クイックフィックス操作
vim.keymap.set("n", "<leader>cn", "<Cmd>cnext<CR>", { noremap = true, desc = "Go to next ctag" })
vim.keymap.set("n", "<leader>cp", "<Cmd>cNext<CR>", { noremap = true, desc = "Go to previous ctag" })
vim.keymap.set("n", "<leader>cf", "<Cmd>cfirst<CR>", { noremap = true, desc = "Go to first ctag" })
vim.keymap.set("n", "<leader>cl", "<Cmd>clast<CR>", { noremap = true, desc = "Go to last ctag" })

-- バッファ切り替え
local switchBuff = function(switching_key)
    -- define buffer switching cmds
    local buf_switching_cmds = {
        next = "bnext",
        prev = "bprev"
    }
    -- validate switching key
    local is_valid = false
    for key, value in pairs(buf_switching_cmds) do
        if key == switching_key then
            is_valid = true
            break
        end
    end
    if is_valid == false then
        vim.notify("invalid argument. switching key must be next or prev", vim.log.levels.ERROR, { title = "switchBuff" })
        return
    end

    -- block buffer switching on specified buffer
    local block_table = {
        "bufctl_bufnr",
        "fim_input_bufnr",
        "fim_selector_bufnr",
        "eim_main_bufnr",
    }
    for i = 1, #block_table do
        local block_bufnr = block_table[i]
        if vim.fn.exists("g:" .. block_bufnr) and (vim.fn.bufnr() == vim.g[block_bufnr]) then
            vim.notify("バッファ切り替えがブロックされたよ", vim.log.levels.WARN, { title = "switchBuff" }) -- warning
            return
        end
    end

    -- switch buffer
    local buf_switching_cmd = buf_switching_cmds[switching_key]
    while true do
        vim.cmd(buf_switching_cmd)
        -- skip "nolisted" or "terminal"
        if (vim.opt.buflisted:get() ~= 0) and (vim.opt.buftype:get() ~= "terminal") then
            vim.notify("バッファを" .. vim.fn.escape(vim.fn.bufname(vim.fn.bufnr()), "\\") .. "へ切り替えたよ", vim.log.levels.INFO,
                { title = "switchBuff" })
            break
        end
    end
end

vim.keymap.set("n", "<Leader>l", "", {
    noremap = true,
    callback = function()
        switchBuff("next")
    end,
    desc = "次のバッファへ",
})
vim.keymap.set("n", "<Leader>h", "", {
    noremap = true,
    callback = function()
        switchBuff("prev")
    end,
    desc = "前のバッファへ"
})

vim.keymap.set("n", "<Leader>q", "<CMD>bdelete<CR>")
