# ==============================================================================
# プロンプト設定 (Pure zsh + vcs_info)
#
# 特徴:
#   - oh-my-zsh 非依存
#   - vcs_info ベースの Git 状態表示
#   - Conda / VirtualEnv 表示
#   - Ruby バージョン表示 (rbenv)
#   - ~/.box-name によるホスト名エイリアス
#   - 右プロンプトに時計
#
# ==============================================================================

# ------------------------------------------------------------------------------
# zsh 組み込みモジュール
# ------------------------------------------------------------------------------

autoload -Uz colors
autoload -Uz vcs_info
autoload -Uz add-zsh-hook #fix

colors

# PROMPT 内でコマンド置換を有効化
setopt PROMPT_SUBST

# ------------------------------------------------------------------------------
# 色定義
# ------------------------------------------------------------------------------

# 旧 FG[247] に相当
FG_NEUTRAL="%F{247}"

# ------------------------------------------------------------------------------
# ホスト名ヘルパー
# ------------------------------------------------------------------------------

# ~/.box-name が存在すればその内容をホスト名として使う
#
# 例:
#   echo "prod01" > ~/.box-name
#
# プロンプト:
#   ryoma@prod01
#
box_name() {
    local box="${SHORT_HOST:-$HOST}"

    [[ -f ~/.box-name ]] && box="$(<~/.box-name)"

    # % は PROMPT 内で特殊文字なのでエスケープする
    print -r -- "${box//\%/%%}"
}

# ------------------------------------------------------------------------------
# Python 仮想環境ヘルパー
# ------------------------------------------------------------------------------

# 表示例:
#
#   (base)
#   (venv)
#
virtualenv_info() {

    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        printf '(%s) ' "$CONDA_DEFAULT_ENV"
        return
    fi

    if [[ -n "$VIRTUAL_ENV" ]]; then
        printf '(%s) ' "${VIRTUAL_ENV:t}"
    fi
}

# ------------------------------------------------------------------------------
# Ruby バージョンヘルパー
# ------------------------------------------------------------------------------

# 表示例:
#
#   using ‹3.3.0›
#
ruby_prompt_info() {

    local version

    if command -v rbenv >/dev/null 2>&1; then
        version=$(rbenv version-name 2>/dev/null)
    fi

    if [[ -n "$version" ]]; then
        return
    fi

    print -P " %F{239}using%f%F{243} ‹${version}›%f"
}

# ------------------------------------------------------------------------------
# 時計ヘルパー
# ------------------------------------------------------------------------------

clock_info() {
    print "%*"
}

# ------------------------------------------------------------------------------
# vcs_info 設定
# ------------------------------------------------------------------------------

# Git のみ有効
zstyle ':vcs_info:*' enable git

# ステージ済み / 未ステージの変更を検出
zstyle ':vcs_info:git:*' check-for-changes true

# 通常状態
#
# 例:
#
#   [main]
#   [main ●]
#   [main ● ●]
#
zstyle ':vcs_info:git:*' formats "${FG_NEUTRAL}(%b)%f%c%u"

# アクション状態 (merge/rebase 中)
#
# 例:
#
#   [main|rebase]
#   [main|merge]
#
zstyle ':vcs_info:git:*' actionformats "${FG_NEUTRAL}(%b-%a)%f%c%u"

# ファイルがステージ / 変更されたときの記号
zstyle ':vcs_info:git:*' stagedstr '%F{yellow} %f'
zstyle ':vcs_info:git:*' unstagedstr '%F{red} %f'

git_clean() {

    if [ $(git status --short 2>&1 | wc -l) -eq 0 ]; then
        print '%F{green} %f'
    fi
}

# ------------------------------------------------------------------------------
# プロンプト記号
# ------------------------------------------------------------------------------

# Git リポジトリ内:
#
#   󰊤
#
# 通常ディレクトリ:
#
#   
#
# エラー時:
#
#   
#
prompt_char() {

    if [[ -n "$vcs_info_msg_0_" ]]; then
        print '%(?.%F{247}󰊤 %f.%F{red}󰊤 %f)'
    else
        print '%(?.%F{247}󰐌 %f.%F{red} %f)'
    fi
}
# ------------------------------------------------------------------------------
# プロンプト1行目を構築
# ------------------------------------------------------------------------------

prompt_header() {

    local left=""

    left+="${FG_NEUTRAL}╭─%f"

    # ユーザー名
    left+="%B%F{green}%n%f%b"

    # @
    left+="${FG_NEUTRAL}@%f"

    # ホスト名
    left+="%B%F{magenta}$(box_name)%f%b"

    # :
    left+="${FG_NEUTRAL}:%f"

    # カレントディレクトリ
    left+="%B%F{blue}%~%f%b"

    # git ブランチ・状態
    left+="%B${vcs_info_msg_0_}%b"
    left+="%B$(git_clean)%b"

    # Ruby バージョン
    left+="$(ruby_prompt_info)"

    print -r "${left}"

}

# ------------------------------------------------------------------------------
# プロンプト本体
# ------------------------------------------------------------------------------
add-zsh-hook precmd vcs_info
PROMPT='$(prompt_header)%f
${FG_NEUTRAL}╰─%f$(virtualenv_info)$(prompt_char) %f'

RPROMPT="${FG_NEUTRAL}$(clock_info)%f"
