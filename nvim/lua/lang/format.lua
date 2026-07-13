vim.pack.add({
    { src = "https://github.com/stevearc/conform.nvim", },
})
local conform = require("conform")

conform.setup({
    -- ------------------------------------------------------------------------------
    -- ファイルタイプごとにどのフォーマッタを使うかを設定(each lang)
    -- ------------------------------------------------------------------------------
    formatters_by_ft = {
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
    },

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
