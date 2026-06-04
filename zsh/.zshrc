# == パス設定
# opencode
export PATH=/home/rogawa/.opencode/bin:$PATH

# == history設定
HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
#重複無視
setopt HIST_IGNORE_DUPS
#空白無視
setopt HIST_IGNORE_SPACE
#重複を優先的に期限切れにする
setopt HIST_EXPIRE_DUPS_FIRST
#履歴確認時に重複がなくなる
setopt HIST_FIND_NO_DUPS

# == shellの振る舞い
setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT

# == ディレクトリナビゲーション
eval "$(zoxide init zsh)"

# == 補完
# 補完システムを自動ロード
autoload -Uz compinit

# キャッシュデータファイルから補完を初期化
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# 補完で大文字小文字を無視
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# 近似補完を有効化
zstyle ':completion:*' completer _complete _approximate

# 補完候補をメニュー形式で選択する
zstyle ':completion:*' menu select

# 補完候補の色変え
zstyle ':completion:*' list-colors di=34 ln=36 ex=32

# ezaのls補完を再利用する
compdef eza=ls

# == ファジーファインダ
# CTRL_T - ファイル検索
# CTRL_R - 履歴検索
# ALT-C - 選択したディレクトリに移動
# Ubuntu
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    source /usr/share/doc/fzf/examples/completion.zsh
fi

# == 他設定読み込み
# fzf
source "$ZDOTDIR/fzf.zsh"
# エイリアス
source "$ZDOTDIR/aliases.zsh"
# キーバインド
source "$ZDOTDIR/bindings.zsh"
# プラグイン
source "$ZDOTDIR/plugins.zsh"
# プロンプト設定
source "$ZDOTDIR/prompt.zsh"
