vim.pack.add({
    { src = "https://github.com/saghen/blink.lib" },
    { src = "https://github.com/saghen/blink.cmp" },
    { src = "https://github.com/saghen/blink.compat" },
    { src = "https://github.com/rafamadriz/friendly-snippets" },
    {
        src = "https://github.com/L3MON4D3/LuaSnip",
        version = vim.version.range('v2.*'),
        lld = "make install_jsregexp"
    }
})

---@type blink.cmp.Config
local opts = {
    keymap = {
        preset = "super-tab", --補完の決定キー
        -- ['<key>'] = { 'action', 'fallback' } の形式で書く
        ['<C><CR>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-]>'] = { 'snippet_forward', 'fallback' },
        ['<C-[>'] = { 'snippet_backward', 'fallback' },
        ["<C-k>"] = { "scroll_documentation_up", "fallback" },
        ["<C-j>"] = { "scroll_documentation_down", "fallback" },
    },
    cmdline = {
        enabled = true,
        completion = { menu = { auto_show = true } },
        keymap = {
            preset = "super-tab",
            -- ["<CR>"] = { "accept_and_enter", "fallback" },
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
    },
    signature = { window = { border = "rounded" } },
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        -- default = { "lsp", "path", "snippets", "buffer", "crates" },
        -- providers = {
        --     crates = {
        --         name = "crates",
        --         module = "blink.compat.source"
        --     }
        -- }
    },

    snippets = { preset = "luasnip" },
    fuzzy = {
        -- versionを指定してないとバイナリが特定できずLuaにfallbackするwarningが表示される
        implementation = "prefer_rust_with_warning",
    },
}
local opts_extend = { "sources.default" }


-- 補完設定
local cmp = require('blink.cmp')
cmp.build():wait(60000)
cmp.setup(opts)
