# ==============================================================================
# 補完
# ==============================================================================
# ------------------------------------------------------------------------------
# == ビルトイン補完設定
# ------------------------------------------------------------------------------
# 補完システムを自動ロード
autoload -Uz compinit

# キャッシュデータファイルから補完を初期化
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# 補完で大文字小文字を無視
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# 近似補完を有効化
zstyle ':completion:*' completer _complete _approximate

# 隠しファイルも補完候補に含める
zstyle ':completion:*' file-patterns '%p(D) %p'
# 補完候補から除外するディレクトリ
zstyle ':completion:*' ignored-patterns '.git' 'node_modules'

# 補完候補をメニュー形式で選択する(fzf-tabがあるので無効)
# zstyle ':completion:*' menu select

# 補完候補の色変え(fzf-tab側でやる)
# zstyle ':completion:*' list-colors di=34 ln=36 ex=32

# ezaのls補完を再利用する
compdef eza=ls

# ------------------------------------------------------------------------------
# == zsh-completions
_zplugin_load zsh-users zsh-completions
# ------------------------------------------------------------------------------
# 補完ソースを追加
fpath=("${ZDOTDIR}/plugins/zsh-completions/src" $fpath)

# ------------------------------------------------------------------------------
# == zsh-autosuggestions
# 履歴から補完
_zplugin_load zsh-users zsh-autosuggestions
# ------------------------------------------------------------------------------
