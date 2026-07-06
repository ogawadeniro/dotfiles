local cs_setups = {
    catppuccin = function()
        vim.pack.add({
            { src = "https://github.com/catppuccin/nvim" },

        })
        require("catppuccin").setup({
            transparent_background = true,
            float = {
                transparent = true,
                solid = false,
            },
        })
        vim.cmd("colorscheme catppuccin-mocha")

        -- ハイライト調整
        local colors = require("assets.palet")
        vim.api.nvim_set_hl(0, "String", { fg = colors.syntax.string })
        vim.api.nvim_set_hl(0, "Number", { fg = colors.syntax.number })
        -- vim.api.nvim_set_hl(0, "@variable", { fg = colors.syntax.variable })
        vim.api.nvim_set_hl(0, "@property", { fg = colors.syntax.property })
        vim.api.nvim_set_hl(0, "@variable.member", { link = "@property" })
        vim.api.nvim_set_hl(0, "@variable.member", { link = "@property" })
        vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { -- シンタックスハイライトは残しつつ、未使用感を出していく
            fg = "none",
            bg = "#252a25",
            underline = true,
        })
    end,

    nightfox = function()
        vim.pack.add({
            { src = "https://github.com/EdenEast/nightfox.nvim" },
        })
        vim.cmd("colorscheme nightfox")
    end,

    vscode = function()
        vim.pack.add({
            { src = "https://github.com/mofiqul/vscode.nvim" }
        })
        require('vscode').setup({
            transparent = true,         -- 背景を透過する
            disable_nvimtree_bg = true, -- nvim-treeの背景も透過する場合
            group_overrides = {
                ["Comment"] = { fg = '#9399b2' },
            }
        })
        vim.cmd("colorscheme vscode")
    end,
}

cs_setups.catppuccin()
vim.api.nvim_set_hl(0, "Folded", { bg = "#19345a" })

local test = ""
local unused = function()
    vim.print("this is unused function")
end
