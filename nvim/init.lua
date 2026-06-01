-- ╭────────────────────────────────────────╮
-- │ ╭─╮ ╭──╭─╮ ╭─╮╭─────╮╭─╮  ╭─╮╭─╮╭────╮ │
-- │ │ │ │  │ │ │ │╰─╮ ╭─╯│ │  │ ││ ││ ╭╮ │ │
-- │ │ │ │    │ │ │  │ │  │ ╰─╮│ ╰╯ ││ ╰╯ │ │
-- │ ╰─╯ ╰─╯──╯ ╰─╯  ╰─╯  ╰───╯╰────╯╰─╯╰─╯ │
-- ╰─────────────────────────────── rogawa ─╯

-- luaファイル一括読み込み用関数
local function import_plugins(target, excludes)
    excludes = excludes or {}
    local dirpath = vim.fn.stdpath("config") .. "/lua/" .. target
    local handle = vim.loop.fs_scandir(dirpath)

    local name
    while handle do
        -- ファイル名取得
        name = vim.loop.fs_scandir_next(handle)
        if not name then -- 終了、何も残っていない
            break
        end

        -- バリデーション
        -- luaファイルかどうかチェック
        local package_name = string.match(name, "(.+)%.lua")
        if package_name == nil then goto continue end

        -- 除外チェック
        local is_exclude = false
        for _, exclude in ipairs(excludes) do
            if package_name == exclude then
                is_exclude = true
                break
            end
        end
        if is_exclude then goto continue end

        local package_path = target .. "." .. package_name
        require(package_path)
        --vim.notify(package_path .. "がrequireされました")

        ::continue::
    end
end

-- コア設定読み込み
import_plugins("core")

-- カスタム設定読み込み
import_plugins("custom")

-- プラグイン設定読み込み
import_plugins("plugins")

-- 言語設定読み込み
import_plugins("lang")


-- ╭──────────────────────────╮
-- │ ╭╮╭─╭╮╭╮╭──╮ ╭╮ ╭╮╭╮╭──╮ │─╮
-- │ │││ ││││╰╮╭╯ ││ │││││╭╮│ │ │
-- │ ││││││││ ││  ││ │││││╰╯│ │ │
-- │ ││││ │││ ││╭╮│╰╮│╰╯││╭╮│ │ │
-- │ ╰╯╰╯─╯╰╯ ╰╯╰╯╰─╯╰──╯╰╯╰╯ │ │
-- ╰──────────────────────────╯ │
--  ╰───────────────── rogawa ──╯
-- 移行してない
-- gitsigns.lua
-- lazygit.lua
-- lsp-signeture.lua

-- お試しプラグイン
