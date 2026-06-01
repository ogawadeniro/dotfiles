vim.pack.add({
    { src = "https://github.com/stevearc/conform.nvim", },
})
local conform = require("conform")

conform.setup({
    -- ファイルタイプごとにどのフォーマッタを使うか
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
    },

    -- フォーマッタの個別設定
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

    -- Set this to change the default values when calling conform.format()
    -- This will also affect the default values for format_on_save/format_after_save
    default_format_opts = {
        lsp_format = "fallback",
    },
    format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
    },
    -- Conform will notify you when a formatter errors
    notify_on_error = true,
    -- Conform will notify you when no formatters are available for the buffer
    notify_no_formatters = false,
})
