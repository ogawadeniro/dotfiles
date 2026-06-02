-- [ rustaceanvim設定 ]
vim.pack.add({
    {
        src = "https://github.com/mrcjkb/rustaceanvim",
        version = vim.version.range('^9')
    }, -- version = '^9',

})

-- [ nvim-dap設定 ]
vim.pack.add({
    { src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://github.com/rcarriga/nvim-dap-ui" }, -- nvim-dap, nvim-nioに依存
    { src = "https://github.com/nvim-neotest/nvim-nio" }
})

local dap = require("dap")
local dapui = require("dapui")
--dap開閉設定
dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open()
end

dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
end
--dapui有効化
dapui.setup()


-- [crate設定]
vim.pack.add({
    { src = "https://github.com/saecki/crates.nvim", version = "stable" }
})
local crates = require("crates")
crates.setup(
    {
        lsp = {
            enabled = true,
            actions = true,
            completion = true,
            hover = true,
        },
        completion = {
            cmp = {
                enabled = true,
            },
            crates = {
                enabled = true,  -- disabled by default
                max_results = 8, -- The maximum number of search results to display
                min_chars = 3    -- The minimum number of charaters to type before completions begin appearing
            }
        },
    }
)
--keymap
local augrp_crate = vim.api.nvim_create_augroup("UserOpenCargo", {})
vim.api.nvim_create_autocmd({ "BufRead" }, {
    pattern = { "Cargo.toml" },
    group = augrp_crate,
    callback = function()
        local opts = { silent = true }
        vim.keymap.set("n", "<leader>ct", crates.toggle, { desc = "crates.toggle" })
        vim.keymap.set("n", "<leader>cr", crates.reload, { desc = "crates.reload" })

        vim.keymap.set("n", "<leader>cv", crates.show_versions_popup, { desc = "crates.show_versions_popup" })
        vim.keymap.set("n", "<leader>cf", crates.show_features_popup, { desc = "crates.show_features_popup" })
        vim.keymap.set("n", "<leader>cd", crates.show_dependencies_popup,
            { desc = "crates.show_dependencies_popup" })

        vim.keymap.set("n", "<leader>cu", crates.update_crate, { desc = "crates.update_crate" })
        vim.keymap.set("v", "<leader>cu", crates.update_crates, { desc = "crates.update_crates" })
        vim.keymap.set("n", "<leader>ca", crates.update_all_crates, { desc = "crates.update_all_crates" })
        vim.keymap.set("n", "<leader>cU", crates.upgrade_crate, { desc = "crates.upgrade_crate" })
        vim.keymap.set("v", "<leader>cU", crates.upgrade_crates, { desc = "crates.upgrade_crates" })
        vim.keymap.set("n", "<leader>cA", crates.upgrade_all_crates, { desc = "crates.upgrade_all_crates" })

        vim.keymap.set("n", "<leader>cx", crates.expand_plain_crate_to_inline_table,
            { desc = "crates.expand_plain_crate_to_inline_table" })
        vim.keymap.set("n", "<leader>cX", crates.extract_crate_into_table,
            { desc = "crates.extract_crate_into_table" })

        vim.keymap.set("n", "<leader>cH", crates.open_homepage, { desc = "crates.open_homepage" })
        vim.keymap.set("n", "<leader>cR", crates.open_repository, { desc = "crates.open_repository" })
        vim.keymap.set("n", "<leader>cD", crates.open_documentation, { desc = "crates.open_documentation" })
        vim.keymap.set("n", "<leader>cC", crates.open_crates_io, { desc = "crates.open_crates_io" })
        vim.keymap.set("n", "<leader>cL", crates.open_lib_rs, { desc = "crates.open_lib_rs" })
    end
})
