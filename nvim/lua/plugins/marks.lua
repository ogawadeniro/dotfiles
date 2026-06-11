vim.pack.add({
    { src = "https://github.com/chentoast/marks.nvim" },
})
require('marks').setup({
    -- キーバインドをマッピングするかどうか。 デフォルトはtrue。
    -- default_mappings = true,
    -- どの組み込みマークを表示するか。 デフォルトは{}
    builtin_marks = { ".", "<", ">", "^" },
    -- マークの表示優先度を下げる
    sign_priority = { lower = 1, upper = 1, builtin = 1, bookmark = 1 },
    -- disables mark tracking for specific filetypes. default {}
    excluded_filetypes = {},
    -- disables mark tracking for specific buftypes. default {}
    excluded_buftypes = {
        "terminal",
        "nofile",
        "acwrite",
        "prompt",
    },
    -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
    -- sign/virttext. Bookmarks can be used to group together positions and quickly move
    -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
    -- default virt_text is "".
    -- bookmark_0 = {
    --     sign = "⚑",
    --     virt_text = "",
    --     -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
    --     -- defaults to false.
    --     annotate = true,
    -- },
})
