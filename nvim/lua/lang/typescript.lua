vim.pack.add({
    -- { src = "nvim-lua/plenary.nvim" }, -- 依存プラグイン
    -- { src = "neovim/nvim-lspconfig" }, -- 依存プラグイン
    { src = "https://github.com/pmizio/typescript-tools.nvim" }
})


require("typescript-tools").setup {}
