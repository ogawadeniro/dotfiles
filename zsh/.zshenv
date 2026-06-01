# ~/.zshenv bk
# . "$HOME/.cargo/env"

# -- XDBベースディレクトリ
# config, cache, data の配置を集中化
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# -- エディタ
# gitやcrontabで使われるデフォルトエディタを設定
export EDITOR="nvim"
export VISUAL="nvim"

# -- GPG
export GPG_TTY=$(tty)

# -- PATH
# ユーザローカルのバイナリやスクリプトのパス設定
export PATH="$HOME/.local/bin:$PATH"
