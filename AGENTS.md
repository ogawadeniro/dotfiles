# AGENTS.md — rogawa/.dotfiles

個人用 dotfiles (zsh, nvim, tmux, ghostty, opencode)

## インストール

```sh
./install.sh   # ~/.config/{ghostty,nvim,tmux,zsh,opencode} -> ~/.dotfiles/{ghostty,nvim,tmux,zsh,opencode}
```

設定ファイルは `~/.dotfiles/` 以下を編集する。**`~/.config/` は触らない。**

## Zsh

- `ZDOTDIR` = `~/.config/zsh/` — `/etc/zsh/zshenv` で設定
- プラグインマネージャは `zsh/helpers.zsh`:
  - `_zplugin_load user repo` — 初回に depth=1 clone し `repo.plugin.zsh` を source
  - `_zplugin_load_part user repo path` — sparse checkout で一部のみ取得
- `.zshrc` 読み込み順（重要）: helpers → aliases → bindings → prompt → **zsh-vi-mode** → completions → **fzf.zsh** → fast-syntax-highlighting
- **zsh-vi-mode は fzf-tab より前に読み込む必要がある**。zsh-vi-mode の deferred init が後からキーバインドを上書きするため
- fzf-tab: `zsh/fzf.zsh` で `_zplugin_load aloxaf fzf-tab` → zsh-vi-mode 初期化後に `zvm_after_init_commands` で再 source が必要な場合あり
- fzf-tab の `fzf-flags` は複数 zstyle 行に分けると後者が前者を上書きする。**1行にまとめること**
- 依存: zoxide, fzf, fd-find (または fdfind), eza, bat (または batcat)。Ubuntu では `batcat`/`fdfind` 名。これらは `.zshrc` の `CMD_BAT`/`CMD_FD` で設定
- `plugins/` は `.gitignore` 対象
- 隠しファイル補完: `setopt GLOB_DOTS` (`completions.zsh`) — `file-patterns` だけでは `cd` に効かない
- 除外パターン: `zstyle ':completion:*' ignored-patterns` (`completions.zsh`)
- `zstyle ':completion:*' menu no` 必須 (fzf-tab 用)

## Neovim

- Pure Lua、lazy.nvim 不使用。`vim.pack` (組み込み) + `nvim-pack-lock.json` でプラグイン管理
- `:PackUpdate` でプラグイン更新 (`lua/core/pack.lua`)
- `init.lua` が `lua/{core,custom,plugins,lang}/` 配下の `.lua` を自動 require。ファイルを作成するだけでよく、手動 `require` 不要
- 読み込み順: `core` → `custom` → `plugins` → `lang`
- 言語サポート追加時は `lua/lang/lsp.lua`, `lua/lang/format.lua`, `lua/lang/highlight.lua` を編集し、treesitter パーサをインストール
- **`lsp.lua` : 各言語 LSP は `server_opts` にエントリ（空でも `{}`）が必要。ないと `vim.lsp.enable()` が静かにスキップ**
- LSP キーマップ（`LspAttach` 時、`g` 接頭辞）: `K` ホバー, `gf` フォーマット, `gd` 定義, `gt` 型定義, `gr` 参照, `gi` 実装, `gn` リネーム, `ga` コードアクション, `ge` 診断表示, `g]`/`g[` 次/前診断
- **`bufctl.lua` のハイライト競合に注意**: `matchadd` の `\v[^\]/]+$` は行内に `]` `/` がないと行全体にマッチし、extmark より上位の優先度を持つ。devicon 色を表示したい場合は当該 matchadd を削除し、`nvim_buf_set_extmark` + `priority` でアイコン・ファイル名を個別にハイライトする
- bufctl のハイライト方式: icon + devicon hl_group → extmark (priority 200)、filename → extmark with Normal (priority 100)、term filename → extmark with `BufCtlTermName` (#a6e3a1)。`▶` / `` / `No Name` / `Term:` のみ matchadd で処理
- bufctl ウィンドオプション: `winhighlight = Cursor:NormalFloat` (カーソル非表示), `cursorline = true`。閉じる時に `guicursor` を復元
- 外部依存: treesitter-cli (nvim 0.12+)
- Leader: `<Space>`。バッファ切替: `<Leader>h`/`<Leader>l`。Quickfix: `<Leader>c{n,p,f,l}`

## Tmux

- Prefix: `C-j`。ペイン移動: `hjkl`。分割: `prefix V` (横), `prefix H` (縦)。リロード: `prefix r`
- Catppuccin テーマは手動 clone (TPM 不使用):
  ```sh
  git clone -b v2.3.0 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
  # ↑ ~/.dotfiles/tmux/plugins/ 配下に展開される（.gitignore 対象）
  ```
- `plugins/` は `.gitignore` 対象。色定義は `palet.conf` に集約。`status.conf` が `source -F` で参照

## OpenCode

- 設定は `~/.dotfiles/opencode/` を編集（`install.sh` が `~/.config/opencode/` へ symlink）
- `opencode.jsonc`: `default_agent = "plan"`、日本語応答指定、bash permission は `*` allow で `rm -rf *` / `sudo *` のみ deny
- `tui.jsonc`: テーマ `catppuccin-macchiato`、leader `ctrl+x`、editor_open `<leader>e`
- npm 依存 `@opencode-ai/plugin` あり

## Ghostty

- テーマ: Catppuccin Mocha。フォントサイズ: 11。背景透過度: 0.91。

## テスト・CI・フォーマッタ・リンターなし

純粋な個人設定。ビルド・検証ステップは存在しない。
