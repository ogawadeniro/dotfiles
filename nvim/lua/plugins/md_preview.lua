-- インラインでマークダウンをプレビュー
vim.pack.add({
    { src = "https://github.com/OXY2DEV/markview.nvim" },
})

---@type markview.config
local opt_markview = {
    preview = {
        enable = false,
    },
}
require("markview").setup(opt_markview)

vim.api.nvim_set_keymap("n", "<leader>mdt", "<CMD>Markview<CR>", { desc = "markrview:マークダウンのプレビューをトグル" });

-- ブラウザでマークダウンプレビュー
vim.pack.add({
    { src = "https://github.com/toppair/peek.nvim" },
})

-- アップデート時のビルドコマンド設定
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        vim.notify("!!!!!!!!!!PackChanged!!!!!!!!!! name: " .. name)
        if name == "peek.nvim" and kind == "update" then
            if not ev.data.active then vim.cmd.packadd("peek") end
            vim.system({ "deno", "task", "--quiet", "build:fast" }, { cwd = ev.data.path })
            -- build = "deno task --quiet build:fast"
            --アップデート時にビルドが走る(ビルドされない場合、以下実行して手動でビルドする。)
            -- cd ~/.local/share/nvim/site/pack/core/opt/peek.nvim && deno task --quiet build:fast
        end
    end
})

-- ブラウザが実行可能なときだけpeekをセットアップする
local app_cmds = {
    { 'google-chrome',        '--new-window' },
    { 'google-chrome-stable', '--new-window' },
}
local app
for _, app_cmd in ipairs(app_cmds) do
    if vim.fn.executable(app_cmd[1]) == 1 then
        app = app_cmd
        break
    end
end
if app then
    require("peek").setup({
        app = app,
    })
    vim.api.nvim_set_keymap("n", "<leader>mdp", "", { callback = require("peek").open, desc = "peek:マークダウンプレビューを開く" })
    vim.api.nvim_set_keymap("n", "<leader>mdo", "", { callback = require("peek").close, desc = "peek:マークダウンプレビューを閉じる" })
else
    vim.notify("peek: 利用可能なブラウザが見つからなかったよ。設定ファイルにブラウザを開くコマンドを追加してね", vim.log.levels.WARN, { title = "peek" })
end
