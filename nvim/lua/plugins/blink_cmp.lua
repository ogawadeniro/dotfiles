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
        preset = "enter", --補完キーマッププリセット
        -- ['<key>'] = { 'action', 'fallback' } の形式で書く
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
        },
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
    },

    snippets = { preset = "luasnip" },
    fuzzy = {
        -- versionを指定してないとバイナリが特定できずLuaにfallbackするwarningが表示される
        implementation = "prefer_rust_with_warning",
    },
}
-- local opts_extend = { "sources.default" }


-- 補完設定
local cmp = require('blink.cmp')
cmp.setup(opts)
cmp.build():pwait()

-- ------------------------------------------------------------------------------
-- blink.cmpアップデート時にbuild()実行(これが動いてるかは不明)
-- ------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "blink.cmp" and kind == "update" then
            vim.notify("blink.nvimがアップデートされたので、build()を実行するよ")
            --cmp.build():pwait()
            cmp.build():pwait()
        end
    end
})
