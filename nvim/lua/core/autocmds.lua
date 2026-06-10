-- insertモード離脱時に自動でIMEオフ
vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
        local ime_cmd = { "fcitx5-remote", "-c" }
        if vim.fn.executable(ime_cmd[1]) then
            vim.system(ime_cmd)
        end
    end,
    desc = "insertモード離脱時に自動でIMEオフ(fcitx5依存)"
})
