# == fzf設定

# ファイル検索コマンド設定(隠しファイル表示)
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
elif command -v fdfind >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --strip-cwd-prefix'
fi

# Ctrl-Tでfzfを開く
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# UIをコンパクトにする
if command -v bat >/dev/null 2>&1; then
    export BAT_CMD='bat'
elif command -v batcat >/dev/null 2>&1; then
    export BAT_CMD='batcat'
fi
export FZF_DEFAULT_OPTS="
    --height 40% 
    --layout=reverse 
    --border 
    --preview '${BAT_CMD} --style=numbers --color=always {}'
"

# Ctrl+F
_fzf_file_no_hidden() {
    local cmd result
    cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
    result=$(eval "${cmd:-find . -type f}" : fzf) && LBUFFER+="$result"
    zle reset-prompt
}

zle -N _fzf_file_no_hidden
