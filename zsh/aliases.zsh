# == ezaでlsをいいかんじにする
alias ls="eza --icons"
alias ll="ls -l --icons --git"
alias la="ls -la --icons --git"
alias tree="eza --tree --icons"

# ==コマンド名短縮
# fd
if command -v fdfind >/dev/null 2>&1; then
    alias fd='fdfind'
fi
# bat
if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi

# == rmをラップして、削除したファイルをゴミ箱に入れるようにする
rm_wrap() {
    local trash_dir=~/.local/share/Trash/files
    mkdir -p "$trash_dir"
    for item in "$@"; do
        if [ -e "$item" ]; then
            mv "$item" "$trash_dir"
            if [ $? -eq 0 ]; then
                echo "Moved to trash: $item"
            else
                echo "Failed to move to trash"
            fi
        else
            echo "rm: cannot remove '$item': No such file or directory" >&2
        fi
    done
}
alias rm=rm_wrap

# 他
alias vim="nvim"
alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='dif -h'
alias dot="nvim ${HOME}/.dotfiles"
