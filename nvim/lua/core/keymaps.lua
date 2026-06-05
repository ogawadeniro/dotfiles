-- ------------------------------------------------------------------------------
-- leaderkey
-- ------------------------------------------------------------------------------
vim.g.mapleader = " "


vim.keymap.set("n", "<leader>r", function()
    vim.cmd("bufdo e!")
end, { desc = "全バッファ再読込" })

-- ------------------------------------------------------------------------------
-- ウィンドウ操作系
-- ------------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------------
-- モード系
-- ------------------------------------------------------------------------------
--  ターミナルでジョブモードを抜ける
vim.keymap.set("t", "<C-[>", "<C-\\><C-N>", { noremap = true, desc = "ターミナルのジョブモードを抜ける" })

-- ------------------------------------------------------------------------------
-- 編集系
-- ------------------------------------------------------------------------------
-- 囲む系文字の内側に移動
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
-- vim.keymap.set({ "i", "c" }, '""', '""<Left>', { noremap = true })
-- vim.keymap.set({ "i", "c" }, "''", "''<Left>", { noremap = true })
-- vim.keymap.set({ "i", "c" }, "()", "()<Left>", { noremap = true })
-- vim.keymap.set({ "i", "c" }, "[]", "[]<Left>", { noremap = true })
-- vim.keymap.set({ "i", "c" }, "{}", "{}<Left>", { noremap = true })
-- vim.keymap.set({ "i", "c" }, "<>", "<><Left>", { noremap = true })
-- vim.keymap.set({ "i", "c" }, "%%", "%%<Left>", { noremap = true })
-- 行末に;を挿入
vim.keymap.set("n", "<leader>;", "", {
    noremap = true,
    callback = function()
        local pos_prev = vim.fn.getpos(".")
        vim.cmd('noautocmd normal! $a;')
        vim.fn.setpos(".", pos_prev)
        vim.cmd('noautocmd normal! a')
        print("セミコロンを入れたよ")
    end,
    desc = "行末にセミコロン挿入"
})
-- 行末セミコロン削除
vim.keymap.set("n", "<leader>g;", "", {
    noremap = true,
    callback = function()
        -- カーソル位置を取得しておく
        local pos_prev = vim.fn.getpos(".")
        -- 行末にセミコロンがあるか判定して削除
        local line = vim.fn.getline(".")
        local is_semicolon = string.match(line, ";$")
        if is_semicolon then
            vim.cmd('noautocmd normal! $x')
            print("さよならセミコロン")
        else
            print("行末にセミコロンはないようだ")
        end
        -- カーソル位置を戻す
        vim.fn.setpos(".", pos_prev)
        vim.cmd('noautocmd normal! a')
    end,
    desc = "行末セミコロン削除"
})

-- ------------------------------------------------------------------------------
-- 移動系
-- ------------------------------------------------------------------------------
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
