-- ------------------------------------------------------------------------------
-- nvim-tree
-- ------------------------------------------------------------------------------
vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-tree.lua" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
})
vim.pack.add({ { src = "https://github.com/3rd/image.nvim" } })
require("image").setup({
    backend = 'kitty',
    processor = 'magick_cli',
    integrations = {
        markdown = {
            enabled = true,
            clear_in_insert_mode = true,
            only_render_image_at_cursor = false,
            floating_windows = false,
        },
    },
    max_height_window_percentage = 50,
})

local nvimtree = require('nvim-tree')
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
local treeapi = require('nvim-tree.api')
local icons = require("assets.icons")

local gheight = vim.api.nvim_list_uis()[1].height
local gwidth = vim.api.nvim_list_uis()[1].width
local width = math.floor(gwidth / 2)
local height = gheight - 4

---@type nvim_tree.config
local opts = {
    view = {
        -- float を有効化する
        float = {
            enable = true,
            quit_on_focus_loss = true, -- ツリー外を非表示（フォーカスが外れたら閉じる）
            open_win_config = {
                title = " Nvim Tree ",
                title_pos = "center",
                relative = "editor",
                width = width,
                height = height,
                row = math.floor((gheight - height) * 0.5),
                col = math.floor((gwidth - width) * 0.5),
            },

        },
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
                    -- unmerged = icons.git.unmerged,
                    -- renamed = icons.git.renamed,
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
    end,
}
nvimtree.setup(opts)

-- highlihght settings
vim.cmd("hi NvimTreeGitDirty guifg=#f39c12")
vim.cmd("hi NvimTreeGitStagedIcon guifg=#1acd94")
vim.cmd("hi NvimTreeGitNew guifg=#1a9dc4")
-- vim.cmd("hi NvimTreeExecFile    guifg=#ffa0a0")
-- vim.cmd("hi NvimTreeSpecialFile guifg=#ff80ff gui=underline")
-- vim.cmd("hi NvimTreeSymlink     guifg=Yellow  gui=italic   ")
-- vim.cmd("hi link NvimTreeImageFile   Title                      ")

-- ------------------------------------------------------------------------------
-- mini files
-- ------------------------------------------------------------------------------
vim.pack.add({
    { src = "https://github.com/nvim-mini/mini.nvim" },
})
require('mini.files').setup({
    mappings = {
        go_in_plus = '<CR>', -- Enterでディレクトリに入る
        go_out_plus = '-',   -- マイナスで上の階層へ
    },
})

-- ------------------------------------------------------------------------------
-- keymap
-- ------------------------------------------------------------------------------
-- nvim-tree
vim.keymap.set('n', '<Leader>e', "<CMD>NvimTreeFocus<CR>")
-- mini files
vim.keymap.set('n', '<Leader>E', function()
    require('mini.files').open(vim.api.nvim_buf_get_name(0))
end, { desc = 'Open mini.files in current directory' })

-- mini files
