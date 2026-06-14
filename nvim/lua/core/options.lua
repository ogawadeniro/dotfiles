-- setで設定されるような一般的な設定を書く

-- 一般設定
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorcolumn = false
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmode = false
vim.opt.wrap = false
vim.opt.hidden = true
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.scrolloff = 3

-- タブ、インデント系
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.autoindent = true
vim.opt.smartindent = true

-- バックアップファイルを作成しないようにする
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = false

-- ファイルエンコーディング系
vim.opt.encoding = "utf-8"
vim.opt.fileencodings = { "utf-8", "sjis" }
vim.opt.fileformats = { "unix", "mac", "dos" }
-- vim.opt.ambiwidth = 'double'
vim.opt.ambiwidth = "single"
vim.cmd("language en_US.utf8")

-- クリップボード設定
vim.opt.clipboard:append({ "unnamedplus" })
--vim.g.clipboard = "xclip"

-- UI文字系
vim.opt.list = true
vim.opt.fillchars:append({
    fold = " ",
    horiz = "─",
    horizup = "┴",
    horizdown = "┬",
    vert = "│",
    vertleft = "┤",
    vertright = "├",
    verthoriz = "┼",
})
vim.opt.listchars:append({ tab = "^-", space = "_", eol = "$" })
vim.opt.matchpairs:append({ "<:>" })

-- path
vim.opt.path:append("**")

-- マウス無効
vim.opt.mouse = ""

-- 色
vim.opt.termguicolors = true
-- vim.opt.winblend = 0
-- vim.opt.pumblend = 0

-- シェル
local shell = "zsh"
if vim.fn.executable(shell) == 1 then
    vim.opt.shell = shell
end

-- ui2有効化
require('vim._core.ui2').enable({})
