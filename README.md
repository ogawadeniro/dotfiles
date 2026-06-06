# rogawa/.dotfiles

ドットファイルたちを一括管理するためのリポジトリだよ  
完全に個人用だよ  

`./install.sh` を実行すると、本当のコンフィグディレクトリに symlink されるよ  

以下、各ツールが依存している外部ツールやセットアップ方法について記載するよ  

---

# 共通

## 必要外部ツール


| ツール | 用途 |
|---|---|
| **Nerd Font** |イカしたアイコンを表示 |


---

# Zsh

## 必要外部ツール

| ツール | 用途 |
|---|---|
| **zoxide** | ディレクトリ移動補完 |
| **fzf** | ファジーファインダ。履歴検索, fzf-tab など |
| **eza** | ls をかっこよくする |
| **bat** / **batcat** | cat の代替。fzf のプレビューをかっこよくする |
| **fd** / **fdfind** | find の代替 |
| **ripgrep** (rg) | grep の代替 |
| **nvim** | デフォルトエディタ |

## あると嬉しい外部ツール

| ツール | 用途 |
|---|---|
| **tldr** | コマンドヘルプ。なくても man が出るよ |
| **rbenv** | Ruby バージョン表示。なくても何もしないよ |


## zsh初期セットアップ
1. zshインストール  
2. /etc/zsh/zshenvを編集してコンフィグパスを変更  
3. /.config/zshにzshの設定ファイルを配置  
4. zsh起動  

```bash /etc/zsh/zshenv
# 手順2で編集する内容
# パス設定
if [[ -z "$PATH" || "$PATH" == "/bin:/usr/bin" ]]
then
	export PATH="/usr/local/bin:/usr/bin:/bin:/usr/games"
fi

# zsh設定のルート設定
if [[ -z "$XDG_CONFIG_HOME" ]]
then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi
```

---

# Neovim

## バージョン

| **Neovim 0.12+** | `vim.pack` などの新APIを使う |

## 必須外部ツール

| 要件 | 備考 |
|---|---|
| **make + C compiler** | telescope-fzf-native などのビルドに必要 |
| **npm / Node.js** | mason-lspconfig, prettier, markdownlint |
| **Python + pip** | pylsp, black |
| **Rust toolchain** | rust-analyzer, rustfmt |
| **treesitter-cli** | Nvim 0.12+ で Treesitter パーサインストールに必要 |
| **git** | プラグイン管理 |


## 言語設定したいときやること

lang配下のファイルたちを編集する。  

- lsp.lua  
lsp設定追加する。  
設定項目ない場合もserver_optsに対象lsp名のプロパティ追加しないとenable()が実行されないので注意。  

- format.lua  
フォーマッタ設定する。  

- highlight.lua  
treesitterの言語パーサインストールしてなかったらする  
filetypeのautocmdに対象ファイルタイプ追加する。  
  
それ以外にも追加設定必要な場合は言語個別でファイルを作って設定する 。
例: rust(rustaceanivm), typescript(typescript-tools)  

---

# Tmux

特になし  

---

# Ghostty

特になし  

---

# OpenCode

特になし  
