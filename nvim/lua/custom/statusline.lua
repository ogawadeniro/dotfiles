-- ------------------------------------------------------------------------------
-- グローバル
-- ------------------------------------------------------------------------------
--色
local colors = require("assets.palet")
--ステータスがない時に表示する文字列
local STAT_NA = "-"
-- ハイライトリセット文字列
local HL_RESET = "%*"
local hl_ns_id = 0
--セパレータ例:    

-- ------------------------------------------------------------------------------
-- 型定義
-- ------------------------------------------------------------------------------
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
---@field each_mode table<string, SLModeEach>
---@field separator SLSeparator
---@field color_sep SLSeparatorColor

-- バッファ変更状態のオプションの型
---@class SLBufModOpt
---@field disp_str table<string, string>
---@field separator SLSeparator
---@field color vim.api.keyset.highlight
---@field color_sep SLSeparatorColor

--コード診断のseverityとオプションの対応
---@type table<vim.diagnostic.Severity, string>
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

-- formatter状態のオプションの型
---@class SLFmtOpt
---@field fallback_icon string
---@field separator SLSeparator
---@field color vim.api.keyset.highlight
---@field color_sep SLSeparatorColor

---ステータスラインのオプションの型
---@class UserSLOpt
---@field mode SLModeOpt
---@field macro SLCommonOpt
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

---コンポーネント名の型
---@alias SLComponentName "mode"|"macro"|"buf_nr"|"buf_mod"|"fpath"|"diag"|"lsp"|"ts"|"fmt"|"ft"|"ff"|"enc"|"pos"

-- ------------------------------------------------------------------------------
-- コンフィグ
-- ------------------------------------------------------------------------------
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
    buf_nr = { --バッファ番号
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
        --disp_str  = { enable = " ", disable = "" },
        disp_str  = { enable = "󰐅 ", disable = "" },
        separator = { l = "  " },
        color     = { bg = slcolors.bg_nc, fg = colors.green[1] },
        color_sep = { l = { bg = slcolors.bg_nc, fg = slcolors.sep_nc } },
    },
    fmt = { -- formatter
        -- table.insert(names, "%#DiagnosticSignWarn# %*" .. client.name)
        -- table.insert(names, "%#DiagnosticSignWarn# %*" .. client.name)
        --󰦛
        -- fallback_icon = " ",
        -- fallback_icon = " ",
        fallback_icon = "󰦛 ",
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
    enc = { --encoding
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
    local mode_opt = opts.mode.each_mode[mode_expr] or { disp_str = "Unknown", color = { bg = "NONE" } }
    return mode_opt
end

-- マクロ記録状態を表す文字列を取得
-- @return string
local function stat_macro()
    local macro_str = vim.fn.reg_recording()
    if macro_str == "" then
        return STAT_NA
    end
    return "@" .. macro_str
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
end

-- カーソル位置を表す文字列を取得
local function stat_pos_percent()
    local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.fn.line("$")
    local row_percent = math.floor(cursor_row / lines * 100)
    return row_percent .. "%%"
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
local function stat_treesitter()
    if (vim.treesitter.get_node() == nil) then
        return opts.ts.disp_str.disable
    end
    return opts.ts.disp_str.enable
end

---@return table<vim.diagnostic.Severity, string>
local function stat_diagnostics()
    -- アイコンが設定されているか確認
    local d_signs = vim.diagnostic.config().signs
    if not d_signs or d_signs == true then -- signsにアイコンが設定されていないときはtrueになる
        return {}
    end
    -- severityzごとのアイコン設定取得
    local d_icon = d_signs.text
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
-- ------------------------------------------------------------------------------
-- ハイライトヘルパー
local function _hl(hlgroup)
    return "%#" .. hlgroup .. "#"
end

-- セパレータ組み立て関数
---@param hl string
---@param sep_char string?
---@param color vim.api.keyset.highlight
---@return string
local function _render_sep(hl, sep_char, color)
    if not sep_char then return "" end
    vim.api.nvim_set_hl(hl_ns_id, hl, color)
    return _hl(hl) .. sep_char
end

-- 通常コンポーネントを組み立てる関数
---@param name string optsのキー名と一致していないとだめ
---@param text string
---@return string
local function _create_component_common(name, text)
    local entry = opts[name]
    local hl_base = "SL" .. name
    vim.api.nvim_set_hl(hl_ns_id, hl_base, entry.color)
    return _render_sep(hl_base .. "l", entry.separator.l, entry.color_sep.l)
        .. _hl(hl_base) .. text
        .. _render_sep(hl_base .. "r", entry.separator.r, entry.color_sep.r)
end

-- モードコンポーネントを組み立てる関数
---@param name string
---@param opt SLModeEach
---@return string
local function _create_component_mode(name, opt)
    local entry = opts[name]
    local hl_base = string.gsub(("SL" .. name .. opt.disp_str), "%s+", "")
    vim.api.nvim_set_hl(hl_ns_id, hl_base, opt.color)
    local sep_color_r = { fg = opt.color.bg, bg = entry.color_sep.r.bg }
    return _render_sep(hl_base .. "l", entry.separator.l, entry.color_sep.l)
        .. _hl(hl_base) .. opt.disp_str .. HL_RESET
        .. _render_sep(hl_base .. "r", entry.separator.r, sep_color_r) .. " "
end

-- コード診断コンポーネントを組み立てる関数(コード診断が0個でもセパレータは作って返す)
---@param name "diag"
---@param diag_texts table<vim.diagnostic.Severity, string>
---@return string
local function _create_component_diagnostics(name, diag_texts)
    local hl_base = "SL" .. name
    local entry = opts[name]
    local diag_stats = {}
    for severity, text in pairs(diag_texts) do
        if text ~= "" then
            local severity_name = sl_severity[severity]
            local hl_severity = hl_base .. severity_name
            vim.api.nvim_set_hl(hl_ns_id, hl_severity, entry.each_severity[severity_name].color)
            table.insert(diag_stats, _hl(hl_severity) .. text)
        end
    end
    local combined_diag_stats = table.concat(diag_stats, " ")
    return _render_sep(hl_base .. "l", entry.separator.l, entry.color_sep.l)
        .. combined_diag_stats .. HL_RESET
        .. _render_sep(hl_base .. "r", entry.separator.r, entry.color_sep.r)
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
    end
    return _create_component_common(name, text) -- .." "はワークアラウンド
end

---@type table<string, fun(name:string, stat:any):string>
local builders = {
    mode = _create_component_mode,
    diag = _create_component_diagnostics,
    ft = _create_component_ft,
}

---コンポーネント作成のディスパッチャ
---@param name SLComponentName
---@param stat any
---@return string
local function create_component(name, stat)
    local builder = builders[name] or _create_component_common
    return builder(name, stat)
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
        create_component("diag", stat_diagnostics()),
        create_component("lsp", stat_lsp()),
        create_component("ts", stat_treesitter()),
        create_component("fmt", stat_formatter() .. " "),
        -- create_component("pos", " " .. stat_pos()),
        create_component("pos", stat_pos()),
        create_component("ff", stat_ff()),
        create_component("enc", stat_enc()),
        create_component("ft", stat_ft() .. " "),
    }

    return table.concat(components)
end

-- ステータスラインを適用
vim.opt.statusline = "%!v:lua.StatusLine()"
