-- leaderkey設定
vim.g.mapleader = " "

-- [モード系]
--  ターミナルでジョブモードを抜ける
vim.keymap.set("t", "<C-[>", "<C-\\><C-N>", { noremap = true, desc = "Exit job mode on terminal" })

-- [編集系]
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

-- [移動系]
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
    desc = "Switch buffer to next",
})
vim.keymap.set("n", "<Leader>h", "", {
    noremap = true,
    callback = function()
        switchBuff("prev")
    end,
    desc = "Switch buffer to previous"
})
