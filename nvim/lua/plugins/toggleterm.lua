vim.pack.add({
    { src = "https://github.com/akinsho/toggleterm.nvim" },
})

-- toggle term
require("toggleterm").setup({
    -- size = function(term)
    --   if term.direction == "vertical" then
    --       return vim.o.columns * 0.4
    --   else
    --       return 15
    --   end
    -- end,
    -- ターミナルを開閉するキーマップ
    open_mapping = [[<c-\>]], -- or { [[<c-\>]], [[<c-¥>]] } if you also use a Japanese keyboard.
    -- ターミナルの開き方
    direction = "float",
    -- フローティングウィンドウのオプション
    float_opts = {
        width = math.floor(vim.opt.columns:get() / 2),
        col = math.floor(vim.opt.columns:get() / 2),
        row = 1,
        height = vim.opt.lines:get() - 2,
        title_pos = 'center'
    },

    persist_size = false,
})

vim.api.nvim_create_autocmd({ "TermOpen" }, {
    pattern = { "term://*" },
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        -- TODO
        -- normalモードで<C-l>でターミナル画面を左に寄せるとかしたい
        -- require("toggleterm").toggle()でトグルできる
        -- exコマンドで開くときしかオプションを渡せないっぽいので、mapに渡すターミナルを開く関数は自作関数でラップする
    end
})

-- ターミナルのウィンドウリサイズ時にサイズが変更されていないのでVimResizedトリガーで設定をもう一度適用する(だめでした。)
-- setupはプラグインガロードされるときに一回だけしか呼ばれないので他の方法で設定を適用できれば動く
-- vim.api.nvim_create_autocmd({ 'VimResized' }, {
--     callback = function()
--         require("toggleterm").setup({
--             float_opts = {
--                 width = math.floor(vim.opt.columns:get() / 2),
--                 col = math.floor(vim.opt.columns:get() / 2),
--                 row = 1,
--                 height = vim.opt.lines:get() - 2,
--                 title_pos = 'center'
--             },
--         })
--     end
-- })
