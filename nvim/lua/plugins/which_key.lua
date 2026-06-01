vim.pack.add({
    { src = "https://github.com/folke/which-key.nvim" }
})

-- init = function()
--     vim.o.timeout = true
--     vim.o.timeoutlen = 500
-- end

local opts = {
    win = {
        border = "rounded", -- none, single, double, shadow
    },
}

require("which-key").setup(opts)
