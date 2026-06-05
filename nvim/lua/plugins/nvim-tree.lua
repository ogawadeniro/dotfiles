-- 依存プラグイン
vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-tree.lua" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
})

local nvimtree = require('nvim-tree')
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
local treeapi = require('nvim-tree.api')
local icons = require("assets.icons")
---@type nvim_tree.config
local opts = {
    view = {
        width = 30,
        -- relativenumber = false,
    },
    renderer = {
        group_empty = false,
        indent_markers = {
            enable = true,
        },
        icons = {
            glyphs = {
                git = {
                    unstaged = icons.git.unstaged.icon,
                    staged = icons.git.staged.icon,
                    -- unmerged =icons.git.--.icon,
                    -- renamed =icons.git.--.icon,
                    untracked = icons.git.untracked.icon,
                    deleted = icons.git.deleted.icon,
                    ignored = icons.git.ignored.icon,
                }
            }
        }
    },
    actions = {
        open_file = {
            window_picker = {
                enable = false,
            }
        },
        file_popup = {
            open_win_config = {
                border = "rounded",
            },
        }
    },
    filters = {
        -- dotfiles = true,
        custom = {},
    },
    git = {
        ignore = false,
    },
    on_attach = function(bufnr)
        local function opts(desc)
            return {
                desc = "nvim-tree: " .. desc,
                buffer = bufnr,
                noremap = true,
                silent = true,
                nowait = true
            }
        end

        -- デフォルトマッピング
        -- treeapi.config.mappings.default_on_attach(bufnr)
        treeapi.map.on_attach.default(bufnr)

        -- カスタムマッピング
        -- 十字キーでディレクトリ展開（ウィンドウリサイズモード中はリサイズ優先）
        vim.keymap.set('n', '<Right>', function()
            if vim.g._resize_mode then
                vim.cmd("vertical resize +1")
            else
                treeapi.node.open.edit()
            end
        end, opts('開く'))
        vim.keymap.set('n', '<Left>', function()
            if vim.g._resize_mode then
                vim.cmd("vertical resize -1")
            else
                treeapi.node.navigate.parent_close()
            end
        end, opts('フォルダを畳む'))

        vim.keymap.set('n', 'zM', treeapi.tree.collapse_all, opts('フォルダをすべて畳む'))
        vim.keymap.set('n', 'zR', treeapi.tree.expand_all, opts('フォルダをすべて展開'))
        -- ヘルプの表示/非表示切り替え
        vim.keymap.set('n', '?', treeapi.tree.toggle_help, opts('Help'))
        -- 画像ビュワーで開く
        vim.keymap.set('n', 'i', function()
            -- カーソル下のノードを取得
            local node = treeapi.tree.get_node_under_cursor()
            -- パス取得
            local abs_path = node.absolute_path

            -- 画像ファイルでない場合は終了
            -- TODO luaの正規表現でパイプが使えない。いままでどうしてたっけ。
            local ext = string.match(abs_path, "%..+$") or ""               -- 対象ファイルの拡張子
            local image_ext_list = { "jpeg", "jpg", "png", "svg", "webp", } -- 画像ファイル拡張子の一覧
            local is_image_file = false                                     -- 画像ファイルかどうか

            for _, image_ext in ipairs(image_ext_list) do
                if "." .. image_ext == ext then
                    is_image_file = true
                    break
                end
            end
            -- 画像ファイルではない場合は、メッセージを出して終了。
            if is_image_file == false then
                vim.notify(
                    "選択した'" .. ext .. "' は画像ファイルじゃないみたい。 \n" ..
                    "もし画像ファイルなのにこのメッセージが表示されていたら、設定ファイルの変数image_ext_listに拡張子を追加してね",
                    vim.log.levels.WARN, { title = "nvim-tree" })
                return
            end

            -- osごとに画像ビュワーを変更
            local cmd = ""
            if vim.fn.has('linux') then
                cmd = "eog " .. abs_path
            elseif vim.fn.has('win32') or vim.fn.has('win64') then
                cmd = ""
                -- cmd = 'powershell -Command Invoke-Item " ' .. abs_path .. '"'
            end
            -- コマンドを設定していないOSは何もしない
            if cmd == "" then
                vim.notify("このOSでは画像ビュワーを開くコマンドが設定されてないみたい。\nもし動かしたかったら設定ファイルに追加してね", vim.log.levels.ERROR,
                    { title = "nvim-tree" })
                return
            end

            -- 画像ビュワーを非同期で開く
            vim.fn.jobstart(cmd)
        end, opts('Open: Image viewer'))
    end,
}

nvimtree.setup(opts)

-- keymap settings
local keymap = vim.keymap
keymap.set('n', '<Leader>e', "<CMD>NvimTreeFocus<CR>")

-- highlihght settings
vim.cmd("hi NvimTreeGitDirty guifg=#f39c12")
vim.cmd("hi NvimTreeGitStagedIcon guifg=#1acd94")
vim.cmd("hi NvimTreeGitNew guifg=#1a9dc4")
-- vim.cmd("hi NvimTreeExecFile    guifg=#ffa0a0")
-- vim.cmd("hi NvimTreeSpecialFile guifg=#ff80ff gui=underline")
-- vim.cmd("hi NvimTreeSymlink     guifg=Yellow  gui=italic   ")
-- vim.cmd("hi link NvimTreeImageFile   Title                      ")
