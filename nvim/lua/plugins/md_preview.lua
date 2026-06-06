-- インラインでマークダウンをプレビュー
vim.pack.add({
    { src = "https://github.com/OXY2DEV/markview.nvim" },
})

vim.api.nvim_set_keymap("n", "<leader>mdt", "<CMD>Markview<CR>", { desc = "markrview:マークダウンのプレビューをトグル" });

-- ブラウザでマークダウンプレビュー
vim.pack.add({
    { src = "https://github.com/toppair/peek.nvim" },
})

-- アップデート時のビルドコマンド設定
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "peek" and kind == "update" then
            if not ev.data.active then vim.cmd.packadd("peek") end
            vim.system({ "deno", "task", "--quiet", "build:fast" }, { cwd = ev.data.path })
            -- build = "deno task --quiet build:fast"
        end
    end
})

require("peek").setup({
    app = { 'google-chrome', '--new-window' }
})

vim.api.nvim_set_keymap("n", "<leader>mdp", "", { callback = require("peek").open, desc = "peek:マークダウンプレビューを開く" })
vim.api.nvim_set_keymap("n", "<leader>mdo", "", { callback = require("peek").close, desc = "peek:マークダウンプレビューを閉じる" })
