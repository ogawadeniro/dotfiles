vim.pack.add({
    { src = "https://github.com/stevearc/conform.nvim", },
    { src = 'https://github.com/williamboman/mason.nvim' },
    { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
})

-- ファイルタイプごとにフォーマッタを指定
local formatters_by_ft = {
    -- yaml = { "prettier" },
    -- json = { "prettier" },
    make = { "checkmake" },
    markdown = { "markdownlint" },
    -- markdown = { "prettier" },
    python = { "black" },
    c = { "clang-format" },
    rust = { "rustfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    sh = { "shfmt" },
    toml = { "taplo" }
}
local exclude_auto_install = { "rustfmt" }

-- インストールするフォーマッタを抽出
local install_formatters = {}
for _, formatters in pairs(formatters_by_ft) do
    for _, formatter in pairs(formatters) do
        table.insert(install_formatters, formatter)
    end
end
vim.list.unique(install_formatters)
-- 自動インストール除外対象のフォーマッタを除外
for i, formatter in ipairs(install_formatters) do
    for _, exclude in ipairs(exclude_auto_install) do
        if formatter == exclude then
            table.remove(install_formatters, i)
            break
        end
    end
end

-- フォーマッタ自動インストール設定
require('mason-tool-installer').setup {
    ensure_installed = install_formatters,
    auto_update = false,
    run_on_start = true,
}


-- conform設定
local conform = require("conform")

conform.setup({
    -- ------------------------------------------------------------------------------
    -- ファイルタイプごとにどのフォーマッタを使うかを設定(each lang)
    -- ------------------------------------------------------------------------------
    formatters_by_ft = formatters_by_ft,

    -- ------------------------------------------------------------------------------
    -- フォーマッタの個別設定(each lang)
    -- ------------------------------------------------------------------------------
    formatters = {
        prettier = {},
        black = {
            prepend_args = { "--line-length", "90" },
        },
        isort = {
            prepend_args = {
                "--profile",
                "black",
            },
        },
    },

    -- ------------------------------------------------------------------------------
    -- 他設定
    -- ------------------------------------------------------------------------------
    -- conform.format() のデフォルト値を変更する場合はここを設定
    -- format_on_save / format_after_save のデフォルト値にも影響する
    default_format_opts = {
        lsp_format = "fallback",
    },
    -- 保存時にフォーマットするかどうか
    format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
    },
    -- フォーマッタがエラーを吐いた時に通知する
    notify_on_error = true,
    -- 有効なフォーマッタがない時に通知する
    notify_no_formatters = false,
})
