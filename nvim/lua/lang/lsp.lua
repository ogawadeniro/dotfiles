vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/mason-org/mason.nvim" },
})

local icons = require("assets.icons")

--Mason有効化(lspをMasonでインストールせず、システム側などでインストールする場合は不要。)
require("mason").setup({})

--共通設定定義
local server_opts = {
    -- lua
    lua_ls = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim", "use" },
                },
                workspace = {
                    -- Neovim のランタイムファイルを読み込ませる
                    library = vim.api.nvim_get_runtime_file("lua", true),
                    checkThirdParty = false,
                },
                completion = {
                    callSnippet = "Replace",
                },
                doc = {
                    privateName = { "^_" },
                },
                hint = {
                    enable = true,
                    setType = false,
                    paramType = true,
                    paramName = "Disable",
                    semicolon = "Disable",
                    arrayIndex = "Disable",
                },
            },
        },
    },
    pylsp = {},
    bashls = {
        filetypes = { "sh", "bash", "zsh" }, -- 必要に応じて "zsh" などを追加
    },
}
local opts = {
    -- capability共通設定
    capabilities = {
        textDocument = {
            completion = {
                completionItem = {
                    snippetSupport = true,
                },
            },
            foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
            },
            formatting = {
                dynamicRegistration = true, -- lsp側でフォーマッタを自動で設定するかどうか
            },
        },
        -- TODOこれなんだっけ
        workspace = {
            fileOperations = {
                didRename = true,
                willRename = true,
            },
        },
    },
    -- コード診断設定
    diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = false,
        -- virtual_text = {
        -- spacing = 4,
        -- source = "if_many",
        -- virt_text_pos = 'right_align'
        -- -- prefix = "●",
        -- },
        severity_sort = true,
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = icons.status.error.icon,
                [vim.diagnostic.severity.WARN] = icons.status.warn.icon,
                [vim.diagnostic.severity.HINT] = icons.operation.hint.icon,
                [vim.diagnostic.severity.INFO] = icons.status.info.icon,
            },
        },
        float = { border = "rounded" },
    },
    -- ヒント設定
    -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
    -- Be aware that you also will need to properly configure your LSP server to
    -- provide the inlay hints.
    inlay_hints = {
        enabled = true,
        exclude = {}, -- filetypes for which you don't want to enable inlay hints
    },
    -- コードレンズ設定
    -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
    -- Be aware that you also will need to properly configure your LSP server to
    -- provide the code lenses.
    codelens = {
        --enabled = true,
        enabled = false,
    },
}

-- LSPAttachイベント発火時にキーマップを設定する
local function map(buf, mode, lhs, cmd, desc)
    local rhs = "<cmd>lua " .. cmd .. "<CR>"
    local opt = {
        buffer = buf,
        silent = true,
        desc = desc or cmd, --descを指定しなかった場合はマップ対象のコマンドにする
    }
    vim.keymap.set(mode, lhs, rhs, opt)
end

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(e)
        -- lsp系
        map(e.buf, "n", "K", "vim.lsp.buf.hover({border='rounded',with=100})", "シンボルの情報を表示")
        map(e.buf, "n", "gf", "vim.lsp.buf.format()", "コードをフォーマット")
        map(e.buf, "n", "gd", "vim.lsp.buf.definition()", "定義元へジャンプ")
        map(e.buf, "n", "gt", "vim.lsp.buf.type_definition()", "型定義へジャンプ")
        -- map(e.buf, "n", "gD", "vim.lsp.buf.declaration()", "宣言元へジャンプ()") --多くのLSPでは未定義なので基本definition()を使えばいい
        map(e.buf, "n", "gr", "vim.lsp.buf.references()", "参照を一覧表示")
        map(e.buf, "n", "gi", "vim.lsp.buf.implementation()", "実装を一覧表示")
        map(e.buf, "n", "gn", "vim.lsp.buf.rename()", "コードアクションを実行")
        map(e.buf, "n", "ga", "vim.lsp.buf.code_action()", "コードアクションを実行")
        -- コード診断系 :h vim-diagnostic
        map(e.buf, "n", "ge", "vim.diagnostic.open_float()", "コード診断を開く")
        map(e.buf, "n", "g]", "vim.diagnostic.goto_next()", "次のコード診断へジャンプ")
        map(e.buf, "n", "g[", "vim.diagnostic.goto_prev()", "前のコード診断へジャンプ")
    end,
})

-- LSPAttachイベント発火時にinlayhintを有効化する
if opts.inlay_hints.enabled then
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(e)
            local buffer = e.buf ---@type number
            -- local client = vim.lsp.get_client_by_id(e.data.client_id)
            if
                vim.api.nvim_buf_is_valid(buffer)
                and vim.bo[buffer].buftype == ""
                and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
            then
                vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
            end
        end,
    })
end

-- コードレンズ設定(参照回数とかがわかる)
if opts.codelens.enabled then
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(e)
            local buffer = e.buf ---@type number
            vim.lsp.codelens.enable(true, { bufnr = buffer })
            --vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
                buffer = buffer,
                callback = function()
                    vim.lsp.codelens.enable(true)
                end
            })
        end,
    })
end

-- コード診断設定
vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

-- サーバ個別設定を適用してLSP有効化
for name, opt in pairs(server_opts) do
    local config = vim.deepcopy(opt)
    local capabilities = vim.tbl_deep_extend( --capability設定をマージ
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("blink.cmp").get_lsp_capabilities() or {}, -- blink.cmpのキャパビリティ
        opts.capabilities,
        opt.capabilities or {}                             -- サーバ個別のcapability設定
    )
    config.capabilities = capabilities
    -- setup実行
    vim.lsp.config(name, config)
    vim.lsp.enable(name)
    -- vim.notify("lsp["..server_name.."]を有効化したよ")
end
