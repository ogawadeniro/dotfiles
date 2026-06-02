vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" } --パーサーインストール用。実際のハイライト設定とかはnvim組み込みになったらしい
})

-- ------------------------------------------------------------------------------
-- treesitterアップデート時にTSUpdateを実行する
-- ------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "nvim-treesitter" and kind == "update" then
            vim.cmd("TSUpdate")
            vim.notify("treesitterをアップデートしたのでTSUpdateを実行したよ")
        end
    end
})

-- ------------------------------------------------------------------------------
-- lsp側でのハイライト無効化(:Inspectを実行した時に出るSyntaxというやつ)
-- ------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(e)
        local client = vim.lsp.get_client_by_id(e.data.client_id)
        if not client then return end
        -- セマンティックハイライトを無効化
        client.server_capabilities.semanticTokensProvider = nil
    end,
})

-- ------------------------------------------------------------------------------
-- ファイルタイプ適用時にtreesitterを有効にする(each lang)
-- ------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
    -- パーサーが存在している言語だけ対象にする
    pattern = {
        "c",
        "lua",
        "markdown",
        "vimscript",
        "vimdoc",
        "query", --treesitter query files |ft-query-plugin|
        -- ↑ここまではnvimデフォルトでパーサが存在する
        -- ↓ここからは自力orTSInstallでパーサをインストールする必要あり
        "rust",
        "python",
        "cpp",
        "yaml",
        "json",
        "bash",
        "sh",
        "zsh",
        "hcl",
        "terraform",
        "gitignore",
    },
    callback = function(e)
        -- イベントからファイルタイプ取得
        local ft = e.match
        -- ファイルタイプから言語を取得
        local lang
        --if string.match(ft, "%..+rc") then
        if string.match(ft, ".*sh") then
            lang = "bash"
        else
            lang = ft
        end
        -- treesitter有効化
        local success = pcall(vim.treesitter.start, e.buf, lang)
        if success == false then
            vim.notify("Treesitterを有効化できなかったよ", vim.log.levels.WARN, { title = "treesitter" })
            -- else
            --     vim.notify("treesitterを有効にしたよ")
        end
    end
})
