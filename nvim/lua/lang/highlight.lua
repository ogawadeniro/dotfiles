vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" } --パーサーインストール用。実際のハイライト設定とかはnvim組み込みになったらしい
})
-- ------------------------------------------------------------------------------
-- 設定
-- ------------------------------------------------------------------------------
-- インストールするパーサのリスト
local install_parsers = {
    "c",
    "lua",
    "markdown",
    "vimscript",
    "vimdoc",
    "query", --treesitter query files
    -- ↑ここまではnvimデフォルトでパーサが存在する
    -- ↓ここからは自力orTSInstallでパーサをインストールする必要あり
    "rust",
    "python",
    "cpp",
    "yaml",
    "json",
    "bash",
    "hcl",
    "terraform",
    "gitignore",
    "zsh",
    "tmux",
}

-- ファイルタイプとパーサの対応表(ftとパーサ名が違うものだけ定義)
local ft_parser_compat = {
    ["sh"] = "bash",
    ["jsonc"] = "json",
}

-- treesitterを有効にするファイルタイプ名のリスト
local filetypes = vim.deepcopy(install_parsers)
for ft, _ in pairs(ft_parser_compat) do
    table.insert(filetypes, ft)
end

-- ------------------------------------------------------------------------------
-- 自動インストール設定
-- ------------------------------------------------------------------------------
require('nvim-treesitter').install({ install_parsers })

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
    pattern = filetypes,
    callback = function(e)
        -- イベントからファイルタイプ取得
        local ft = e.match
        -- ファイルタイプから言語を取得
        local lang
        -- イベントで受け取ったファイルタイプが、ファイルタイプとパーサーの対応表に存在したらそのパーサを指定する
        -- 一致しなかった場合はファイルタイプ名と同じパーサを指定する(大体はこっち)
        if ft_parser_compat[ft] ~= nil then
            lang = filetypes[ft]
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
