vim.pack.add({
    -- { src = "nvim-lua/plenary.nvim" }, -- 依存プラグイン
    -- { src = "neovim/nvim-lspconfig" }, -- 依存プラグイン
    { src = "https://github.com/pmizio/typescript-tools.nvim" }
})


require("typescript-tools").setup({
    -- その他の設定 (on_attachなど)
    settings = {
        -- ...
        tsserver_format_options = {
            convertTabsToSpaces = true,
            indentSize = 2,
            tabSize = 2,
        },
    },
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { "typescript", "typescriptreact" },
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
})
