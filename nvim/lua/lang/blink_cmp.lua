vim.pack.add({
    { src = "https://github.com/rafamadriz/friendly-snippets" },
    {
        src = "https://github.com/L3MON4D3/LuaSnip",
        version = vim.version.range('v2.*'),
        lld = "make install_jsregexp"
    },
    { src = "https://github.com/saghen/blink.lib" },
    { src = "https://github.com/saghen/blink.compat" },
    { src = "https://github.com/saghen/blink.cmp" },
})

-- friendly-snippets読み込み
require("luasnip.loaders.from_vscode").lazy_load()

---@type blink.cmp.Config
local opts = {
    keymap = {
        preset = "none", --補完キーマッププリセット
        -- ['<key>'] = { 'action', 'fallback' } の形式で書く
        ["<CR>"] = { "accept", "fallback" },
        ['<C-n>'] = {
            function(cmp)
                if cmp.is_active() then
                    cmp.select_next()
                end
                cmp.show()
            end
        },
        -- ['<A-Right>'] = { 'snippet_forward', 'fallback' },
        -- ['<A-Left>'] = { 'snippet_backward', 'fallback' },
        -- ["<C-k>"] = { "scroll_documentation_up", "fallback" },
        -- ["<C-j>"] = { "scroll_documentation_down", "fallback" },
    },
    cmdline = {
        enabled = true,
        completion = {
            menu = { auto_show = true },
            list = { selection = { preselect = false, auto_insert = true } },
        },
        keymap = {
            preset = "super-tab",
            ["<CR>"] = { "accept", "fallback" },
        },
    },
    appearance = {
        nerd_font_variant = "mono",
    },
    completion = {
        documentation = {
            auto_show = true, -- ドキュメントを勝手に開くかどうか
            window = { border = "rounded" },
        },
        ghost_text = { enabled = false },
        menu = { border = "rounded" },
        list = { selection = { preselect = false, auto_insert = true } },
        -- accept = {
        --     auto_brackets = {
        --         enabled = true,
        --     },
        -- },
    },
    signature = { window = { border = "rounded" } },
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },

    snippets = { preset = "luasnip" },
    fuzzy = {
        -- versionを指定してないとバイナリが特定できずLuaにfallbackするwarningが表示される
        implementation = "prefer_rust_with_warning",
    },
}
-- local opts_extend = { "sources.default" }


-- 初期化
local cmp = require('blink.cmp')
--アップデート時にビルドが走る(ビルドされない場合、以下実行して手動でビルドする。)
-- cd ~/.local/share/nvim/site/pack/core/opt/blink.cmp && cargo build --release
cmp.build():pwait()
cmp.setup(opts)
