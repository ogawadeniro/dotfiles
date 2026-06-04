# rogawa/.dotfiles

ドットファイルたちを一括管理するためのリポジトリだよ  
完全に個人用だよ  

`./install.sh` で `~/.config/` 以下に symlink されるよ

---

## 依存いろいろ

### 共通

- **Nerd Font** — イカしたアイコンを表示するために必要だよ

### Zsh

#### 必須なやつ

| ツール | 用途 |
|---|---|
| **zoxide** | ディレクトリ移動補完 |
| **fzf** | ファジーファインダ。履歴検索, fzf-tab など |
| **eza** | ls をいい感じにする |
| **bat** / **batcat** | cat の代替。fzf のプレビューをいい感じにする |
| **fd** / **fdfind** | find の代替 |
| **ripgrep** (rg) | grep の代替 |
| **git** | プラグインマネージャとしても使う |
| **nvim** | デフォルトエディタ |

#### あると嬉しいやつ

| ツール | 備考 |
|---|---|
| **tldr** | コマンドヘルプ。なくても man が出るよ |
| **rbenv** | Ruby バージョン表示。なくても何もしないよ |

#### 自動で取ってくるプラグイン

| リポジトリ | 用途 |
|---|---|
| `jeffreytse/zsh-vi-mode` | 高機能 vi モード |
| `ohmyzsh/ohmyzsh` (plugins/git) | git エイリアス・関数 |
| `zsh-users/zsh-history-substring-search` | 部分一致履歴検索 |
| `aloxaf/fzf-tab` | Tab補完を fzf で |
| `zdharma-continuum/fast-syntax-highlighting` | シンタックスハイライト |
| `zsh-users/zsh-completions` | 追加補完定義 |
| `zsh-users/zsh-autosuggestions` | 履歴補完候補表示 |

---

### Neovim

#### 必要なもろもろ

| 要件 | 備考 |
|---|---|
| **Neovim 0.12+** | `vim.pack` などの新APIを使う |
| **make + C compiler** | telescope-fzf-native などのビルドに必要 |
| **npm / Node.js** | mason-lspconfig, prettier, markdownlint |
| **Python + pip** | pylsp, black |
| **Rust toolchain** | rust-analyzer, rustfmt |
| **treesitter-cli** | Nvim 0.12+ で Treesitter パーサインストールに必要 |
| **git** | プラグイン管理 |

#### プラグイン (vim.pack + nvim-pack-lock.json)

`lua/{core,custom,plugins,lang}/` にファイルを作るだけで自動読み込み:

- LSP: `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig.nvim`
- Treesitter: `nvim-treesitter`
- 補完: `blink.cmp`, `LuaSnip`, `friendly-snippets`
- ファジーファインダ: `telescope.nvim`, `telescope-fzf-native.nvim`
- ファイルツリー: `nvim-tree.lua`, `oil.nvim`
- カラースキーム: `catppuccin`, `nightfox`, `tokyonight`, `vscode.nvim`
- Git: `gitsigns.nvim`
- UI: `bufferline.nvim`, `toggleterm.nvim`, `nvim-notify`, `dressing.nvim`
- その他: `which-key.nvim`, `lsp_signature.nvim`, `scrollbar.nvim`, `rustaceanvim`, `crates.nvim`, `hlchunk.nvim`, `tiny-cmdline.nvim`, `nvim-dap` + `nvim-dap-ui`, `markdown.nvim`, `namu.nvim`, `marks.nvim`, `hlslens.nvim`, `plenary.nvim`, `web-devicons` など

#### LSPサーバ (Mason が自動インストール)

`lua/lang/lsp.lua`: `lua_ls`, `pylsp`, `clangd`, `bashls`, `jsonls`, `yamlls`, `marksman`, `dockerls`, `ansiblels`, `cmake`, `lemminx`, `jdtls`, `openscad_lsp`, `terraformls`, `rust_analyzer`

#### Treesitterパーサ (`:TSInstall <lang>`)

`rust`, `python`, `cpp`, `yaml`, `json`, `bash`, `hcl`, `terraform`, `gitignore`, `zsh`, `tmux`

#### フォーマッタ (conform.nvim)

| フォーマッタ | 対応言語 |
|---|---|
| **prettier** | YAML, JSON, Makefile |
| **markdownlint** | Markdown |
| **black** | Python (--line-length 90) |
| **clang-format** | C / C++ |
| **rustfmt** | Rust |
| **shfmt** | Shell |

---

### Tmux

- **zsh** — デフォルトシェル
- **git** — ブランチ表示
- **catppuccin/tmux** (v2.3.0) — テーマ（手動 clone）
- macOS では **pbcopy** が必要（Linux は未設定）

---

### Ghostty

| 設定 | 値 |
|---|---|
| theme | Catppuccin Mocha（内蔵） |
| font-size | 11 |
| 背景透過度 | 0.91 |
| shell | `/bin/zsh` |

---

### OpenCode

| 依存 | バージョン |
|---|---|
| Node.js / npm | 適当に |
| `@opencode-ai/plugin` | 1.15.13 |

設定: `opencode.jsonc` (Plan エージェント, 日本語応答), `tui.jsonc` (Catppuccin Macchiato)
