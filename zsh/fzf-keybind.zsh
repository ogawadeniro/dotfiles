# ------------------------------------------------------------------------------
# あいまい検索
# ------------------------------------------------------------------------------

# == キーバインド読み込み
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    source /usr/share/doc/fzf/examples/completion.zsh
fi

# ファイル検索コマンド設定(隠しファイル表示)
export FZF_DEFAULT_COMMAND="${CMD_FD} --type f --hidden --strip-cwd-prefix --exclude .git"

# UIをコンパクトにする
export FZF_DEFAULT_OPTS="
    --height 40% 
    --layout=reverse 
    --border 
    --preview '${CMD_BAT} --style=numbers --color=always {}'
"

# == キーバインド
# Ctrl-T ファイル検索
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Ctrl+Rでコマンド履歴を検索
function fzf-select-history() {
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER" --reverse)
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history

# Ctrl+bで移動履歴を辿れる
function fzf-cdr() {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | fzf --reverse)
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N fzf-cdr
