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

# ------------------------------------------------------------------------------
# == fzf-tab設定
_zplugin_load aloxaf fzf-tab
# ------------------------------------------------------------------------------
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept --preview-window=right:80%
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
# tmuxのポップアップ機能で補完メニューが開く?
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
# ファイルのプレビューを表示
zstyle ':fzf-tab:complete:*:*' fzf-preview "if [[ -d \$realpath ]]; then eza -la --color=always \$realpath; else ${CMD_BAT} --style=numbers --color=always \$realpath; fi"
# コマンドのヘルプを表示
zstyle ':fzf-tab:complete:*:options' fzf-preview 'tldr ${(M)words[1]:-$word} 2>/dev/null || man ${(M)words[1]:-$word} 2>/dev/null || echo "No help available"'
zstyle ':fzf-tab:complete:*:arguments' fzf-preview 'tldr ${(M)words[1]:-$word} 2>/dev/null || man ${(M)words[1]:-$word} 2>/dev/null || echo "No help available"'

zstyle ':completion::complete:cd:*' fzf-preview "${CMD_FD} --hidden --max-depth 1 --color=always \$word"
