vim.pack.add({
    { src = "https://github.com/stevearc/oil.nvim.git" },
})

-- プラグイン設定	 
local oil = require("oil")
require("oil").setup({
  default_file_explorer = false,
  columns = {
    "icon",
    -- "permissions",
    -- "size",
    -- "mtime",
  },
  view_options = {
      show_hidden = true,
  },
	keymaps={
		["q"] = { "actions.close", mode = "n" },
	}
})
vim.keymap.set("n", "<Leader>E", function()
	-- oil.open_float()
	oil.open()
end)
