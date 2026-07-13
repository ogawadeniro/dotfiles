vim.pack.add({
    { src = "https://github.com/ogawadeniro/nvim-translator" }
})

-- APIキーをスクリプトで出力してもらって、それをプラグインに設定する。
local env_path = vim.fn.expand("$HOME/work/scripts/deepl_env.sh")
if vim.fn.executable(env_path) then
    local out = vim.fn.system(env_path)
    local api_key = vim.trim(out)
    require('nvim-translator').setup({
        keymap = {
            { src = "en", dst = "ja", key = "<Leader>?", },
            { src = "ja", dst = "en", key = "<Leader>g?", },
        },
        client = {
            provider = "deepl",
            opt = {
                url = "https://api-free.deepl.com/v2/translate",
                api_key = api_key,
            }
        }
    })
end
