# AGENTS.md — rogawa/.dotfiles

個人用 dotfiles (zsh, nvim, tmux, ghostty)

## インストール

```sh
./install.sh   # ~/.config/{ghostty,nvim,tmux,zsh} -> ~/.dotfiles/{ghostty,nvim,tmux,zsh}
```

設定ファイルは `~/.dotfiles/` 以下を編集する。**`~/.config/` は触らない。**

## Zsh

- `ZDOTDIR` = `~/.config/zsh/` — `/etc/zsh/zshenv` で設定
- プラグインマネージャは自作 (`zsh/plugins.zsh`): `_zplugin_load user/repo` で初回に depth=1 clone し、`repo.plugin.zsh` を source
- 依存: zoxide, fzf, fd-find (または fdfind), eza, bat (または batcat)
- `plugins/` と `tmux/plugins/` は `.gitignore` 対象。git は自作設定のみ追跡

## Neovim

- Pure Lua、lazy.nvim 不使用。`vim.pack` (組み込み) + `nvim-pack-lock.json` でプラグイン管理
- `:PackUpdate` でプラグイン更新 (`lua/core/pack.lua` で定義)
- `init.lua` が `lua/{core,custom,plugins,lang}/` 配下の `.lua` を自動 require。ファイルを作成するだけでよく、手動 `require` 不要
- 読み込み順: `core` -> `custom` -> `plugins` -> `lang`
- 言語サポート追加時は `lua/lang/lsp.lua`, `lua/lang/format.lua`, `lua/lang/highlight.lua` を編集し、treesitter パーサをインストール
- 外部依存: treesitter-cli (nvim 0.12+ で必要)
- Leader: `<Space>`。バッファ切替: `<Leader>h`/`<Leader>l`。Quickfix: `<Leader>c{n,p,f,l}`

## Tmux

- Prefix: `C-j` (デフォルトの `C-b` ではない)。リロード: `prefix` + `r`
- Catppuccin テーマは手動で clone (TPM 不使用):
  ```
  git clone -b v2.3.0 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
  ```
- 色定義は `palet.conf` に集約。`status.conf` が `source -F` で参照

## Ghostty

- テーマ: Catppuccin Mocha。フォントサイズ: 11。背景透過度: 0.91。

## テスト・CI・フォーマッタ・リンターなし

純粋な個人設定。ビルド・検証ステップは存在しない。
