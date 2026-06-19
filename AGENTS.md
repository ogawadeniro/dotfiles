# AGENTS.md — rogawa/.dotfiles

個人用 dotfiles (zsh, nvim, tmux, ghostty, opencode, hypr, waybar, kitty, fastfetch, wlogout, swaync, fontconfig)

## インストール

```sh
./ubuntu_install.sh  # Ubuntu
./arch_install.sh    # Arch
```

設定ファイルは `~/.dotfiles/` 以下を編集する。**`~/.config/` は触らない。**

## Zsh

- `ZDOTDIR` = `~/.config/zsh/` — `/etc/zsh/zshenv` で設定
- プラグインマネージャは `zsh/helpers.zsh`:
  - `_zplugin_load user repo` — 初回に depth=1 clone し `repo.plugin.zsh` を source
  - `_zplugin_load_part user repo path` — sparse checkout で一部のみ取得
- `.zshrc` 読み込み順（重要）: helpers → options → zoxide → aliases → bindings → prompt → **zsh-vi-mode** → ohmyzsh/git → history-substring-search → completions (zsh-completions, zsh-autosuggestions) → **fzf-keybind** → **fzf-tab** → fast-syntax-highlighting
- **zsh-vi-mode は fzf-tab より前に読み込む必要がある**。zsh-vi-mode の deferred init が後からキーバインドを上書きするため
- fzf-tab: `zsh/fzf-tab.zsh` で `_zplugin_load aloxaf fzf-tab` → zsh-vi-mode 初期化後に `zvm_after_init` (bindings.zsh) でキーバインド再設定
- `.zshenv`: `XDG_CONFIG/CACHE/DATA/STATE_HOME` 設定, `EDITOR=nvim`, `PATH` 拡張
- `zplugin_update`: 全プラグインを `git pull --ff-only` で一括更新 (`helpers.zsh`)
- `dot` エイリアス: `nvim ~/.dotfiles` — このリポジトリを開く
- fzf-tab の `fzf-flags` は複数 zstyle 行に分けると後者が前者を上書きする。**1行にまとめること**
- 依存: zoxide, fzf, fd-find (または fdfind), eza, bat (または batcat)。Ubuntu では `batcat`/`fdfind` 名。これらは `.zshrc` の `CMD_BAT`/`CMD_FD` で設定
- `plugins/` は `.gitignore` 対象
- 隠しファイル補完: `setopt GLOB_DOTS` (`options.zsh`) — `file-patterns` だけでは `cd` に効かない
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
- `format_on_save = true` (conform.nvim 経由, `lang/format.lua`)
- **`bufctl.lua` のハイライト競合に注意**: `matchadd` の `\v[^\]/]+$` は行内に `]` `/` がないと行全体にマッチし、extmark より上位の優先度を持つ。devicon 色を表示したい場合は当該 matchadd を削除し、`nvim_buf_set_extmark` + `priority` でアイコン・ファイル名を個別にハイライトする
- bufctl のハイライト方式: icon + devicon hl_group → extmark (priority 200)、filename → extmark with Normal (priority 100)、term filename → extmark with `BufCtlTermName` (#a6e3a1)。`▶` / `` / `No Name` / `Term:` のみ matchadd で処理
- bufctl ウィンドオプション: `winhighlight = Cursor:NormalFloat` (カーソル非表示), `cursorline = true`。閉じる時に `guicursor` を復元
- 外部依存: treesitter-cli (nvim 0.12+)
- `build.sh` — `:PackUpdate` 後など、plugin が自動ビルドされない時の手動ビルド用。peek (deno), telescope-fzf-native (make), blink.cmp (cargo), LuaSnip (make) に対応
- Leader: `<Space>`。バッファ切替: `<Leader>h`/`<Leader>l`。Quickfix: `<Leader>c{n,p,f,l}`
- **`custom/statusline.lua` アーキテクチャ**:
  - config → stat取得 → builder → dispatcher → 組立て の5層
  - config は `slcolors`（一括色変更用の中継）→ `opts`（component設定）の2段構え
  - builder は `_render_sep(hl, sep_char, color)` でセパレータ統一
  - dispatcher は `builders` テーブル（`create_component:491`）でデータ駆動化
  - 新しい component 追加時は `UserSLOpt` + `SLComponentName` に追記し、stat関数とbuilderを書く

## Tmux

- Prefix: `C-j`。ペイン移動: `hjkl`。分割: `prefix V` (横), `prefix H` (縦)。リロード: `prefix r`
- ペイン移動: `prefix m`（`move-pane -h`）、`prefix M`（`move-pane -v`）でプロンプトにウィンドウ番号入力
- レイアウト切替: `prefix R`（`select-layout -n`、巡回）
- コピーモード: `prefix y` 開始, `v` 選択, `y` コピー (macOS: `pbcopy` 必要)
- ペインリサイズ: `prefix Left/Right/Up/Down` で 1 セル (C- で入れ替え)
- 読み込み順: `tmux.conf` → `core.conf` → `keybind.conf` → `status.conf`
- Catppuccin テーマは手動 clone (TPM 不使用):
  ```sh
  git clone -b v2.3.0 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
  # ↑ ~/.dotfiles/tmux/plugins/ 配下に展開される（.gitignore 対象）
  ```
- `plugins/` は `.gitignore` 対象。色定義は `palet.conf` に集約。`status.conf` が `source -F` で参照

## OpenCode

- 設定は `~/.dotfiles/opencode/` を編集（`{ubuntu,arch}_install.sh` が `~/.config/opencode/` へ symlink）
- `opencode.jsonc`: `default_agent = "plan"`、日本語応答指定、bash permission は `*` allow で `rm -rf *` / `sudo *` のみ deny
- `tui.jsonc`: テーマ `catppuccin-macchiato`、leader `ctrl+x`、editor_open `<leader>e`
- npm 依存 `@opencode-ai/plugin` あり

## Ghostty

- テーマ: Catppuccin Mocha。フォントサイズ: 11。背景透過度: 0.91。ウィンドウサイズ: 212x47。
- clipboard-read/write = allow, mouse-hide-while-typing = true

## Kitty

- テーマ: Catppuccin Mocha (`current-theme.conf` を include)
- `clipboard_control` で読み書き許可、`cursor_trail` 有効

## Wayland Desktop (Arch 専用)

hypr/ を編集（`~/.config/hypr/` へ symlink）。

- **Hyprland**: `hyprland.lua` がエントリポイント。`core/` 配下を `require` で分割（autostart, looks, input, keybind, programs）
- **hyprlock.conf**: ロック画面設定
- **hyprpaper.conf**: 壁紙設定（`bg_images/ramu_chan.png`）

その他の Arch 向け設定:

- **waybar/**: `config.jsonc` + `style.css` + `custom/media/` に再生中表示スクリプト
- **wlogout/**: `layout` にログアウト・再起動・シャットダウン等のアクション定義
- **swaync/**: `config.json` + `style.css`
- **fastfetch/**: 主にヘッダ設定

## Fontconfig

- `fonts.conf`: Noto Sans/Serif CJK JP, BIZ UD Gothic, JetBrainsMono Nerd Font Propo をフォールバック設定

