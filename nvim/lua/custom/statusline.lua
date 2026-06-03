-- ------------------------------------------------------------------------------
-- グローバル
-- ------------------------------------------------------------------------------
--色
local colors = require("assets.palet")
--ステータスがない時に表示する文字列
local STAT_NA = "-"
-- ハイライトリセット文字列
local HL_RESET = "%*"
--local hl_ns_id = vim.api.nvim_create_namespace("userStatusLine")
local hl_ns_id = 0
--セパレータ例:    
-- ------------------------------------------------------------------------------
-- 型定義
-- ------------------------------------------------------------------------------
---ハイライトの型
--@class vim.api.keyset.highlight
--@field fg? string
--@field bg? string

--セパレータの型
---@class SLSeparator
---@field l? string
---@field r? string

--セパレータ色の型
---@class SLSeparatorColor
---@field l? vim.api.keyset.highlight
---@field r? vim.api.keyset.highlight

-- 一般的なオプションの型
---@class SLCommonOpt
---@field separator SLSeparator
---@field color vim.api.keyset.highlight
---@field color_sep SLSeparatorColor

-- カーソル位置のオプションの型
---@enum SLPosFmt
local sl_pos_format = {
    percent = 1,
    integer = 2,
    all = 3,
}
---@class SLPosOpt
---@field format SLPosFmt
---@field separator SLSeparator
---@field color vim.api.keyset.highlight
---@field color_sep SLSeparatorColor

-- 各モード状態のオプションの型
---@class SLModeEach
---@field disp_str string
---@field color vim.api.keyset.highlight

-- モード状態のオプションの型
---@class SLModeOpt
---@field each_mode SLModeEach[]
---@field separator SLSeparator
---@field color_sep SLSeparatorColor

-- バッファ変更状態のオプションの型
---@class SLBufModOpt
---@field disp_str table<string, string>
---@field separator SLSeparator
---@field color vim.api.keyset.highlight
---@field color_sep SLSeparatorColor

--コード診断のseverityとオプションの対応
local sl_severity = {
    [vim.diagnostic.severity.ERROR] = "error",
    [vim.diagnostic.severity.WARN] = "warn",
    [vim.diagnostic.severity.INFO] = "info",
    [vim.diagnostic.severity.HINT] = "hint",
}

-- コード診断状態のオプションの型
---@class SLDiagOpt
---@field each_severity table<string, table<string, vim.api.keyset.highlight>>
---@field separator SLSeparator
---@field color vim.api.keyset.highlight
---@field color_sep SLSeparatorColor

-- treesitter状態のオプションの型
---@class SLTSOpt
---@field disp_str table<string,string>
---@field separator SLSeparator
---@field color vim.api.keyset.highlight
---@field color_sep SLSeparatorColor

-- treesitter状態のオプションの型
---@class SLFmtOpt
---@field fallback_icon string
---@field separator SLSeparator
---@field color vim.api.keyset.highlight
---@field color_sep SLSeparatorColor

---ステータスラインのオプションの型
---@class UserSLOpt
---@field mode SLModeOpt
---@field buf_nr SLCommonOpt
---@field buf_mod SLBufModOpt
---@field fpath SLCommonOpt
---@field diag SLDiagOpt
---@field lsp SLCommonOpt
---@field ts SLTSOpt
---@field fmt SLFmtOpt
---@field ft SLCommonOpt
---@field ff SLCommonOpt
---@field enc SLCommonOpt
---@field pos SLPosOpt

-- ------------------------------------------------------------------------------
-- コンフィグ
-- ------------------------------------------------------------------------------
--
local slcolors = {
    fg = colors.fg,
    bg = colors.mono[6],
    sep = colors.mono[3],
    bg_nc = colors.mono[5],
    sep_nc = colors.mono[2],
    mode = {
        normal = colors.blue[8],
        insert = colors.stat.ng,
        visual = colors.green[8],
        command = colors.purple[8],
        terminal = colors.mode.terminal,
    },
    severity = {
        error = colors.stat.error,
        warn = colors.stat.warn,
        info = colors.stat.info,
        hint = colors.stat.hint,
    },
    macro = colors.orange[5]
}
---@type UserSLOpt
local opts = {
    mode = {
        each_mode = {
            ["n"] = { disp_str = " NORMAL", color = { bg = slcolors.mode.normal }, },
            ["i"] = { disp_str = " INSERT", color = { bg = slcolors.mode.insert }, },
            ["R"] = { disp_str = " REPLACE", color = { bg = slcolors.mode.insert }, },
            ["c"] = { disp_str = " COMMAND", color = { bg = slcolors.mode.command }, },
            ["v"] = { disp_str = " VISUAL", color = { bg = slcolors.mode.visual }, },
            ["V"] = { disp_str = " VISUAL-L", color = { bg = slcolors.mode.visual }, },
            ["\22"] = { disp_str = " VISUAL-B", color = { bg = slcolors.mode.visual }, },
            ["t"] = { disp_str = " TERM-JOB", color = { bg = slcolors.mode.terminal }, },
            --"n" | "i" | "R" | "c" | "v" | "V" | "\22" | "t"
        },
        separator = { r = "" },
        color_sep = { r = { bg = slcolors.bg } },
    },
    macro = {
        separator = { r = " " },
        color     = { bg = slcolors.bg, fg = slcolors.macro },
        color_sep = { r = { bg = slcolors.bg } },
    },
    buf_nr = { --バッファが変更されているかどうか
        separator = { r = "  " },
        color     = { bg = slcolors.bg, fg = slcolors.fg },
        color_sep = { r = { fg = slcolors.sep, bg = slcolors.bg } },
    },
    buf_mod = { --バッファが変更されているかどうか
        disp_str  = { dirty = "● ", clean = "" },
        separator = {},
        color     = { bg = slcolors.bg, fg = slcolors.fg },
        color_sep = { l = { bg = "none", fg = slcolors.bg }, r = { bg = "none", fg = slcolors.bg } },
    },
    fpath = {
        separator = { r = "" },
        color     = { bg = slcolors.bg, fg = slcolors.fg },
        color_sep = { r = { bg = "none", fg = slcolors.bg } },
    },
    diag = {
        each_severity = {
            error = { color = { bg = slcolors.bg_nc, fg = slcolors.severity.error } },
            warn = { color = { bg = slcolors.bg_nc, fg = slcolors.severity.warn } },
            info = { color = { bg = slcolors.bg_nc, fg = slcolors.severity.info } },
            hint = { color = { bg = slcolors.bg_nc, fg = slcolors.severity.hint } },
        },
        separator     = { l = "", },
        color         = { bg = slcolors.bg, fg = slcolors.fg },
        color_sep     = { l = { bg = "none", fg = slcolors.bg_nc } },
    },
    lsp = {
        separator = { l = "  " },
        color     = { bg = slcolors.bg_nc, fg = colors.fg },
        color_sep = { l = { bg = slcolors.bg_nc, fg = slcolors.sep_nc } },
    },
    ts = { --treesitter
        disp_str  = { enable = " ", disable = "" },
        separator = { l = "  " },
        color     = { bg = slcolors.bg_nc, fg = colors.green[1] },
        color_sep = { l = { bg = slcolors.bg_nc, fg = slcolors.sep_nc } },
    },
    fmt = { -- formatter
        -- table.insert(names, "%#DiagnosticSignWarn# %*" .. client.name)
        -- table.insert(names, "%#DiagnosticSignWarn# %*" .. client.name)
        --󰦛
        fallback_icon = " ",
        -- fallback_icon = "󰦛 ",
        separator     = {},
        color         = { bg = slcolors.bg_nc, fg = slcolors.fg },
        color_sep     = { l = { bg = slcolors.bg_nc, fg = slcolors.sep_nc } },
    },
    ft = { --filetype
        separator = { l = "  ", r = "" },
        color = { bg = slcolors.bg, fg = slcolors.fg },
        color_sep = { l = { bg = slcolors.bg, fg = slcolors.sep }, r = { bg = slcolors.bg } },
    },
    ff = { --fileformat
        separator = { l = "  ", r = "" },
        color     = { bg = slcolors.bg, fg = slcolors.fg },
        color_sep = { l = { bg = slcolors.bg, fg = slcolors.sep }, r = {} },
    },
    enc = { --encording
        separator = { l = "  ", r = "" },
        color     = { bg = slcolors.bg, fg = slcolors.fg },
        color_sep = { l = { bg = slcolors.bg, fg = slcolors.sep }, r = {} },
    },
    pos = { --カーソルポジション
        format    = sl_pos_format.percent,
        separator = { l = "", r = "" },
        color     = { bg = slcolors.bg, fg = slcolors.fg },
        color_sep = { l = { bg = slcolors.bg_nc, fg = slcolors.bg }, r = {} },

    },
}

-- ------------------------------------------------------------------------------
-- ステータス取得ヘルパー
-- ------------------------------------------------------------------------------
-- モード状態を表すテーブルを取得
---@return SLModeEach
local function stat_mode()
    local mode_expr = vim.fn.mode()
    local mode_opt = opts.mode.each_mode[mode_expr] or { disp_str = "Unknown", color = {} }
    return mode_opt
end

-- マクロ記録状態を表す文字列を取得
-- @return string
local function stat_macro()
    local macro_str = vim.fn.reg_recording()
    if macro_str == "" then
        return STAT_NA
    else
        return "@" .. macro_str
    end
end

---@return string
local function stat_buf_nr()
    return "%n"
end

-- バッファが変更されているかの状態を表す文字列を取得
---@return string
local function stat_buf_mod()
    local stat_str, is_modified = "", vim.o.modified
    if is_modified then
        stat_str = opts.buf_mod.disp_str.dirty
    else
        stat_str = opts.buf_mod.disp_str.clean
    end
    return stat_str
end

-- ファイルパスを取得
---@return string
local function stat_fpath()
    local path = vim.fn.expand("%:~:.")
    if path == "" then return "[No Name]" end

    -- ディレクトリ部分を短縮
    path = string.gsub(path, "([^/][^/]?[^/]?).-/", "%1/")

    return path
    --return "%F"
end

-- カーソル位置を表す文字列を取得
local function stat_pos_percent()
    local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.fn.line("$")
    local row_percent = math.floor(cursor_row / lines * 100)
    return row_percent .. "%%"
    -- return "%c," .. row_percent .. "%%"
end
local function stat_pos_integer()
    return "%c,%l/%L"
end
---@return string
local function stat_pos()
    if (opts.pos.format == sl_pos_format.percent) then
        return stat_pos_percent()
    elseif (opts.pos.format == sl_pos_format.integer) then
        return stat_pos_integer()
    elseif (opts.pos.format == sl_pos_format.all) then
        return stat_pos_percent() .. " " .. stat_pos_integer()
    else
        return ""
    end
end

-- ファイルタイプを表す文字列を取得
---@return string
local function stat_ft()
    local ft = vim.o.ft
    -- ファイルタイプがないときはバッファタイプを表示する(NvimTreeなど)
    if ft == "" then
        return vim.o.bt
    end
    return ft
    -- return "%{&buftype!=''?&buftype:&filetype}"
end

-- ファイルフォーマットを表す文字列を取得
---@return string
local function stat_ff()
    return "%{&fileformat}"
end

-- ファイルエンコーディングを表す文字列を取得
---@return string
local function stat_enc()
    return "%{&fileencoding!=''?&fileencoding:&encoding}"
end

---@return string
local function stat_lsp()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
        return STAT_NA
    end

    local names = {}
    for _, client in ipairs(clients) do
        table.insert(names, client.name)
    end

    return table.concat(names, ",")
end

---@return string
local function stat_formatter()
    local ok, conform = pcall(require, "conform")
    if not ok then return STAT_NA end

    local names = {}
    local conform_formatters = conform.list_formatters_for_buffer()

    for _, name in ipairs(conform_formatters) do
        table.insert(names, name)
    end

    local clients = vim.lsp.get_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
        if client:supports_method("textDocument/formatting") then
            table.insert(names, opts.fmt.fallback_icon .. client.name)
        end
    end

    if #names == 0 then return STAT_NA end
    return table.concat(names, ",")
end


---@return string
local function stat_trresitter()
    if (vim.treesitter.get_node() == nil) then
        return opts.ts.disp_str.disable
    else
        return opts.ts.disp_str.enable
    end
end

---@return table<vim.diagnostic.Severity, string>
local function stat_diagnositcs()
    -- severityzごとのアイコン設定取得
    local d_icon = vim.diagnostic.config().signs.text
    if not d_icon then return {} end

    -- コード診断の情報取得
    local d_counts = vim.diagnostic.count(0)
    local diagnostics = {}
    for severity, d_count in pairs(d_counts) do
        diagnostics[severity] = d_icon[severity] .. d_count
    end

    return diagnostics
end

-- ------------------------------------------------------------------------------
-- ステータスライン文字列組み立てヘルパー
-- create_componentをディスパッチャーにしたらきれいな実装になるけどめんどうくさい
-- ------------------------------------------------------------------------------
-- セパレータを組み立てる関数
---@param hlgroup string
---@param text string
---@param color vim.api.keyset.highlight
---@return string
local function _create_separator(hlgroup, text, color)
    vim.api.nvim_set_hl(hl_ns_id, hlgroup, color)
    local sep_hl_set = "%#" .. hlgroup .. "#"
    local separator = (sep_hl_set or "") .. (text or "") --.. HL_RESET
    return separator
end

-- 通常コンポーネントを組み立てる関数
---@param name string optsのキー名と一致していないとだめ
---@param text string
---@return string
local function _create_component_common(name, text)
    -- オプション調達
    local separator = opts[name].separator
    local color = opts[name].color
    local color_separator = opts[name].color_sep
    -- ハイライトグループ名作成
    local hlgroup = "SL" .. name
    -- ステータス部分組み立て
    vim.api.nvim_set_hl(hl_ns_id, hlgroup, color)
    local hl_set = "%#" .. hlgroup .. "#"
    local stat = hl_set .. text -- .. HL_RESET
    -- 左セパレータ組み立て
    local sep_l = ""
    if separator.l then
        sep_l = _create_separator(hlgroup .. "l", separator.l, color_separator.l)
    end
    -- 右セパレータ組み立て
    local sep_r = ""
    if separator.r then
        sep_r = _create_separator(hlgroup .. "r", separator.r, color_separator.r)
    end
    -- コンポーネント組み立て
    local component = sep_l .. stat .. sep_r
    return component
end

-- モードコンポーネントを組み立てる関数
---@param name string
---@param opt SLModeEach
---@return string
local function _create_component_mode(name, opt)
    -- オプション調達
    local text = opt.disp_str
    local color = opt.color
    local separator = opts[name].separator
    local color_separator = opts[name].color_sep

    -- ハイライトグループ名作成
    local hlgroup = string.gsub(("SL" .. name .. opt.disp_str), "%s+", "")

    -- ステータス部分組み立て
    vim.api.nvim_set_hl(hl_ns_id, hlgroup, color)
    local hl_set = "%#" .. hlgroup .. "#"
    local stat = hl_set .. text .. HL_RESET

    -- 左セパレータ組み立て
    local sep_l = ""
    if separator.l then
        sep_l = _create_separator(hlgroup .. "l", separator.l, color_separator.l)
    end

    -- -- 右セパレータ組み立て
    -- local sep_r = ""
    -- if separator.r then
    --     sep_r = create_separator(hlgroup .. "r", separator.r, color_separator.r)
    -- end
    -- ↓ワークアラウンド
    -- ↓モード背景をいい感じにしたい。
    -- ↓モードは左下固定だろうし一旦いい。
    -- ↓各モードオプションにセパレータ色入れるもしくは、モードのオプションにreverse(bool)を入れてセパレータがでもでもいいように対応するか(後者のほうがきれいに行けそう)
    -- ↓基本モードは塗りつぶすから塗りつぶし系のセパレータ(こういうやつ)固定の想定で作ってもいいかも
    local sep_r = ""
    if separator.r then
        sep_r = _create_separator(hlgroup .. "r", separator.r, { fg = opt.color.bg, bg = color_separator.r.bg }) .. " "
    end
    -- ↑ワークアラウンド

    -- コンポーネント組み立て
    local component = sep_l .. stat .. sep_r
    return component
end

-- コード診断コンポーネントを組み立てる関数(コード診断が0個でもセパレータは作って返す)
---@param name "diag"
---@param diag_texts table<vim.diagnostic.Severity, string>
---@return string
local function _create_component_diagnostics(name, diag_texts)
    local hlgroup = "SL" .. name
    -- 受け取ったコード診断テキストそれぞれに色を付ける
    local diag_stats = {}
    for severity, text in pairs(diag_texts) do
        if text == "" then goto continue end
        local severity_name = sl_severity[severity]
        -- 各severityのコンポーネント組み立て
        local hlgroup_severity = hlgroup .. severity_name
        vim.api.nvim_set_hl(hl_ns_id, hlgroup_severity, opts[name].each_severity[severity_name].color)
        local hl_set = "%#" .. hlgroup_severity .. "#"
        local stat = hl_set .. text
        table.insert(diag_stats, stat)
        ::continue::
    end

    -- コード診断を合体して一つの文字列にする
    local combined_diag_stats = table.concat(diag_stats, " ")

    -- セパレータ組み立て
    local separator = opts[name].separator
    local color_separator = opts[name].color_sep
    -- 左セパレータ組み立て
    local sep_l = ""
    if separator.l then
        sep_l = _create_separator(hlgroup .. "l", separator.l, color_separator.l)
    end

    -- 右セパレータ組み立て
    local sep_r = ""
    if separator.r then
        sep_r = _create_separator(hlgroup .. "r", separator.r, color_separator.r)
    end

    -- コンポーネント組み立て
    local component = sep_l .. combined_diag_stats .. HL_RESET .. sep_r
    return component
end

-- ファイルタイプごとにアイコンと色を設定する
---@return string
local function _create_component_ft(name, text)
    local ok, nwd_icons = pcall(require, "nvim-web-devicons")
    if not ok then
        return _create_component_common(name, text) -- .." "はワークアラウンド(deviconsに渡す時に空白を削除すればいい)
    end
    local ft = string.gsub(text, "%s+", "")
    local ft_icon, ft_icon_fg = nwd_icons.get_icon_color_by_filetype(ft)
    if ft_icon and ft_icon_fg then
        local hlgroup = "SL" .. name .. ft
        vim.api.nvim_set_hl(hl_ns_id, hlgroup, { fg = ft_icon_fg, bg = opts[name].color.bg })
        return string.format("%%#%s# %s ", hlgroup, ft_icon)
    else
        return _create_component_common(name, text) -- .." "はワークアラウンド
    end
end

---コンポーネント作成のディスパッチャ
---@param name "mode" | "macro" | "buf_nr" | "buf_mod" | "fpath" | "diag" | "lsp" | "ts" | "fmt" | "ft" | "ff" | "enc" | "pos"
---@param stat string | table<vim.diagnostic.Severity, string> | SLModeEach
---@return string
local function create_component(name, stat)
    if name == "diag" then
        -- コード診断
        ---@cast stat table<vim.diagnostic.Severity, string>
        return _create_component_diagnostics("diag", stat)
    elseif name == "mode" then
        -- モード
        ---@cast stat SLModeEach
        return _create_component_mode(name, stat)
    elseif name == "ft" then
        --ファイルタイプ
        return _create_component_ft(name, stat)
    else
        --他一般
        ---@cast stat string
        return _create_component_common(name, stat)
    end
end
-- ------------------------------------------------------------------------------
-- ステータスライン組み立て
-- ------------------------------------------------------------------------------
---@return string
StatusLine = function()
    local components = {
        -- 左ステータス
        create_component("mode", stat_mode()),
        create_component("macro", stat_macro()),
        create_component("buf_nr", stat_buf_nr()),
        -- create_component("buf_mod", stat_buf_mod()),
        create_component("fpath", stat_fpath() .. " "),

        -- 中央
        "%<%#StatustatineNC#%=",

        -- 右ステータス
        create_component("diag", stat_diagnositcs()),
        create_component("lsp", stat_lsp()),
        create_component("ts", stat_trresitter()),
        create_component("fmt", stat_formatter() .. " "),
        -- create_component("pos", " " .. stat_pos()),
        create_component("pos", stat_pos()),
        create_component("ff", stat_ff()),
        create_component("enc", stat_enc()),
        create_component("ft", stat_ft() .. " "),
    }

    -- ステータスライン組み立て
    local status_line = ""
    for _, component in ipairs(components) do
        status_line = status_line .. component
    end

    return status_line
end

-- ステータスラインを適用
vim.opt.statusline = "%!v:lua.StatusLine()"
