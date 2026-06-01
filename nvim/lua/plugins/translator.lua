vim.pack.add({
    { src = "https://github.com/ogawadeniro/nvim-translator" }
})
require('nvim-translator').setup({
    keymap = {
        { src = "en", dst = "ja", key = "<Leader>?", },
        { src = "ja", dst = "en", key = "<Leader>g?", },
    }
})
