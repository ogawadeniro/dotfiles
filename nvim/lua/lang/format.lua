vim.pack.add({
    { src = "https://github.com/stevearc/conform.nvim", },
})
local conform = require("conform")

conform.setup({
    -- ------------------------------------------------------------------------------
    -- ファイルタイプごとにどのフォーマッタを使うかを設定(each lang)
    -- ------------------------------------------------------------------------------
    formatters_by_ft = {
        yaml = { "prettier" },
        json = { "prettier" },
        -- markdown = { "prettier" },
        markdown = { "markdownlint" },
        make = { "prettier" },
        -- python = { "black", "isort" },
        python = { "black" },
        c = { "clang-format" },
        rust = { "rustfmt" },
        bash = { "shfmt" },
        sh = { "shfmt" },
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
    -- Set this to change the default values when calling conform.format()
    -- This will also affect the default values for format_on_save/format_after_save
    default_format_opts = {
        lsp_format = "fallback",
    },
    -- 保存時にフォーマットするかどうか
    format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
    },
    -- フォーマッタがエラーを履いた時に通知する
    notify_on_error = true,
    -- 有効なフォーマッタがない時に通知する
    notify_no_formatters = false,
})
