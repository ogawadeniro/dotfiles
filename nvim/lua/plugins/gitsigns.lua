vim.pack.add({
    { src = "https://github.com/lewis6991/gitsigns.nvim" }
})
require('gitsigns').setup({
    on_attach                    = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end
        -- ナビゲーション
        map('n', '<Leader>g]', function()
            if vim.wo.diff then
                vim.cmd.normal({ '<Leader>gn', bang = true })
            else
                gitsigns.nav_hunk('next')
            end
        end, { desc = "次のhunk(変更箇所)へ" })

        map('n', '<Leader>g[', function()
            if vim.wo.diff then
                vim.cmd.normal({ '<Leader>gp', bang = true })
            else
                gitsigns.nav_hunk('prev')
            end
        end, { desc = "前のhunk(変更箇所)へ" })
        -- アクション
        map('n', '<leader>gS', gitsigns.stage_buffer, { desc = "bufferをステージ" })
        map('n', '<leader>gR', gitsigns.reset_buffer, { desc = "bufferのステージをリセット" })
        map('n', '<leader>gp', gitsigns.preview_hunk, { desc = "hunk(変更箇所)をプレビュー" })
        -- map('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = "Undo stage" })
        map('n', '<leader>gb', function() gitsigns.blame_line { full = true } end,
            { desc = "現在行のblame(最後の変更情報)を確認" })
        map('n', '<leader>gw', "<Cmd>Gitsigns toggle_word_diff<CR>", { desc = "変更箇所をハイライト" })
        map('n', '<leader>gD', gitsigns.diffthis, { desc = "diffを確認" })
    end,
    attach_to_untracked          = true,
    current_line_blame           = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts      = {
        virt_text_pos = 'right_align',   -- 'eol' | 'overlay' | 'right_align'
        delay = 500,
    },
    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    preview_config               = {
        border = 'rounded',
    },
})
