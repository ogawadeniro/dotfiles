vim.pack.add({
    { src = "https://github.com/bassamsdata/namu.nvim" }
})

require("namu").setup({
})

vim.api.nvim_set_keymap("n", "<leader>fs", "", {
    callback = function()
        vim.cmd("Nam symbols")
    end
})
