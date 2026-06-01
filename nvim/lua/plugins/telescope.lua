vim.pack.add({
    { src = 'https://github.com/nvim-telescope/telescope.nvim' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim',  name = "telescope-fzf-native" },
})

-- アップデート時のビルド設定
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "telescope-fzf-native" and kind == "update" then
            if not ev.data.active then vim.cmd.packadd("telescope-fzf-native") end
            vim.system({ "make" }, { cwd = ev.data.path })
        end
    end
})

-- キーマップ設定
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- 他設定
local opts = {
    defaults = {
        layout_config = {
            width = 0.95,
        },
        file_ignore_patterns = {
            "%.git/",
            "%.metadata/",
        },
        mappings = {
            i = {
            },
            n = {
            },
        }
    },
    pickers = {
        find_files = {
            hidden = true,
        },
    },
}

require("telescope").setup(opts)
