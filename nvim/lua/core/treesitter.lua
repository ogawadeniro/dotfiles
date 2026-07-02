-- 親ノードが「引数リストのコンテナ」であるかを判定する
local function is_argument_container(node_type)
    return node_type == "parameters"
        or node_type == "arguments"
        or node_type == "formal_parameters"
        or node_type == "argument_list"
        or node_type == "parameter_list"
end

-- ファイル全体から、すべての具体的な引数（a, b, cなど）を正確に抽出する
local function collect_all_arguments(root)
    local all_arguments = {}

    local function traverse(node)
        -- 親ノードが引数リストのコンテナだった場合、その直下にある名前付き子要素はすべて「引数」
        if node:parent() and is_argument_container(node:parent():type()) then
            if node:named() then
                local s_row, s_col = node:start()
                table.insert(all_arguments, { node = node, row = s_row, col = s_col })
            end
        end

        -- 子ノードを再帰的に走査
        for child in node:iter_children() do
            traverse(child)
        end
    end

    traverse(root)
    return all_arguments
end

-- メインのジャンプ処理
local function jump_to_closest_argument(direction)
    local ok, parser = pcall(vim.treesitter.get_parser, 0)
    if not ok or not parser then return end

    local tree = parser:parse()
    if not tree or #tree == 0 then return end
    local root = tree[1]:root() -- 最初のツリーのルートを取得

    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
    cursor_row = cursor_row - 1 -- 0-indexed

    -- 1. すべての引数要素を収集
    local all_arguments = collect_all_arguments(root)

    -- 2. 出現順（上から下、左から右）に正しくソート
    table.sort(all_arguments, function(x, y)
        if x.row == y.row then
            return x.col < y.col
        end
        return x.row < y.row
    end)

    -- 3. 現在のカーソル位置から「最も近い1つ」を特定
    local target = nil
    if direction == "next" then
        for _, arg in ipairs(all_arguments) do
            -- カーソル位置より厳密に後ろにある最初の要素
            if arg.row > cursor_row or (arg.row == cursor_row and arg.col > cursor_col) then
                target = arg
                break
            end
        end
    elseif direction == "prev" then
        for i = #all_arguments, 1, -1 do
            local arg = all_arguments[i]
            -- カーソル位置より厳密に前にある最初の要素
            if arg.row < cursor_row or (arg.row == cursor_row and arg.col < cursor_col) then
                target = arg
                break
            end
        end
    end

    -- 4. カーソルを移動
    if target then
        vim.cmd("normal! m'") -- Ctrl-o 用のジャンプリスト登録
        vim.api.nvim_win_set_cursor(0, { target.row + 1, target.col })
    else
        vim.notify("これ以上、引数要素は見つかりません", vim.log.levels.INFO)
    end
end

-- キーマップ設定
vim.keymap.set('n', ']a', function() jump_to_closest_argument("next") end, { desc = "Next argument element" })
vim.keymap.set('n', '[a', function() jump_to_closest_argument("prev") end, { desc = "Previous argument element" })
