local M = {}
M.stl_colors = require('assets.palet')
M.stl_icons = require('assets.icons')
M.main_colors = M.stl_colors.blue

---@param type "r"|"l"
---@param depth integer
---@param is_end boolean?
M.make_separator = function(type, depth, is_end)
    local sep_list = {
        ['r'] = M.stl_icons.slant.fill_r,
        ['l'] = M.stl_icons.slant.fill_l,
    }
    local hi = ""
    if is_end then
        vim.cmd("hi uStlSepEnd" .. type .. " gui=none guifg=" .. M.main_colors[depth] .. "")
        hi = "%#uStlSepEnd" .. type .. "#"
    else
        hi = "%#uStlSep" .. depth .. "#"
    end
    local sep = hi .. sep_list[type] .. "%*"
    return sep
end

M.stat_mode = function()
    local current_mode_str = vim.fn.mode()
    local mode_list = {
        -- { mode_str = "n", disp_str = "NORMAL",   color = "uModeNormal", },
        -- { mode_str = "i", disp_str = "INSERT",   color = "uModeInsert", },
        -- { mode_str = "R", disp_str = "REPLACE",  color = "uModeInsert", },
        -- { mode_str = "c", disp_str = "COMMAND",  color = "uModeCommand", },
        -- { mode_str = "v", disp_str = "VISUAL",   color = "uModeVisual", },
        -- { mode_str = "V", disp_str = "V-LINE",   color = "uModeVisual", },
        -- { mode_str = "", disp_str = "V-BLOCK",  color = "uModeVisual", },
        -- { mode_str = "t", disp_str = "TERM-JOB", color = "uModeTerm", },
        { mode_str = "n", disp_str = "N", color = "uModeNormal", },
        { mode_str = "i", disp_str = "I", color = "uModeInsert", },
        { mode_str = "R", disp_str = "R", color = "uModeInsert", },
        { mode_str = "c", disp_str = "C", color = "uModeCommand", },
        { mode_str = "v", disp_str = "V", color = "uModeVisual", },
        { mode_str = "V", disp_str = "L", color = "uModeVisual", },
        { mode_str = "", disp_str = "B", color = "uModeVisual", },
        { mode_str = "t", disp_str = "T", color = "uModeTerm", },
    }
    -- "%1*%#mmodeterm# TERMINAL-NORMAL %*"
    local status_line_mode = ""
    local is_match = false
    for i = 1, #mode_list do
        if mode_list[i].mode_str == current_mode_str then
            status_line_mode = status_line_mode .. "%#" .. mode_list[i].color .. "#"
            status_line_mode = status_line_mode .. " " .. mode_list[i].disp_str .. " "
            is_match = true
            break
        end
    end
    if is_match == false then
        status_line_mode = current_mode_str
    end
    status_line_mode = status_line_mode .. "%*"
    return status_line_mode
end

M.stat_modified = function()
    local status_modified = ""
    local is_modified = vim.o.modified
    local icon = ""
    if is_modified == true then
        --icon = M.stl_icons.operation.add.icon
        icon = "+"
    else
        -- icon = M.stl_icons.status.ok.icon
        icon = "-"
    end
    status_modified = icon
    return status_modified
end

-- highlight settings
M.set_highlight = function()
    --local fg_color = string.format("#%x", vim.api.nvim_get_hl(0, { name = "StatusLineNC" }).fg)
    local fg_color = "#201828"
    -- define colors
    for i = 1, #M.main_colors - 1 do
        -- separator colors
        vim.cmd("hi uStlSep" .. i .. " gui=none guifg=" .. M.main_colors[i] .. " guibg=" .. M.main_colors[i + 1] .. "")
        -- status module colors
        vim.cmd("hi uStlStat" .. i .. " gui=bold guifg=" .. fg_color .. " guibg=" .. M.main_colors[i] .. "")
    end

    -- colors of end separator
    vim.cmd("hi uStlSepEndr gui=none")
    vim.cmd("hi uStlSepEndl gui=none")
    -- not current statusline color
    -- vim.cmd("hi StatusLineNC guibg=" .. fg_color .. "")

    vim.cmd("hi uModeNormal gui=bold guifg=" .. fg_color .. " guibg=" .. M.stl_colors.mode.normal)
    vim.cmd("hi uModeInsert gui=bold guifg=" .. fg_color .. " guibg=" .. M.stl_colors.mode.insert)
    vim.cmd("hi uModeVisual gui=bold guifg=" .. fg_color .. " guibg=" .. M.stl_colors.mode.visual)
    vim.cmd("hi uModeCommand gui=bold guifg=" .. fg_color .. " guibg=" .. M.stl_colors.mode.command)
    vim.cmd("hi uModeTerm gui=bold guifg=" .. fg_color .. " guibg=" .. M.stl_colors.mode.terminal)
end

-- main
StatusLine = function()
    -- highlight settings
    M.set_highlight()

    -- create status line
    local stl = ""
    -- left of stl
    stl = stl .. M.stat_mode()
    stl = stl .. "%#uStlStat1#" .. " %n " .. M.make_separator('r', 1)
    stl = stl .. "%#uStlStat2#" .. M.stat_modified() .. M.make_separator('r', 2)
    stl = stl .. "%#uStlStat3#" .. " %F " .. M.make_separator('r', 3, true)

    --center of stl
    stl = stl .. "%<%#StatusLineNC#%="

    --right of stl
    stl = stl .. M.make_separator('l', 4, true) .. "%#uStlStat4#" .. " %c,%l/%L "
    stl = stl .. M.make_separator('l', 3) .. "%#uStlStat3#" .. " %{&buftype!=''?&buftype:&filetype} "
    stl = stl .. M.make_separator('l', 2) .. "%#uStlStat2#" .. " %{&fileformat} "
    stl = stl .. M.make_separator('l', 1) .. "%#uStlStat1#" .. " %{&fileencoding!=''?&fileencoding:&encoding} "
    return stl
end

-- attach status line
vim.opt.statusline = "%!v:lua.StatusLine()"
