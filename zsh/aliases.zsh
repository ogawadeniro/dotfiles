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
            local suffix=""
            for i in $(seq 1 100); do
                local dst="${trash_dir}/$(basename "$item")${suffix}"
                # 捨てる先のパスに同じ名前のファイルがなかったら捨てて終わる
                if [ ! -e "${dst}" ]; then
                    mv "$item" "$dst"
                    if [ $? -eq 0 ]; then
                        echo "Moved to trash: $item"
                        break
                    else
                        echo "Failed to trash: $item"
                    fi
                fi
                # 同じ名前のファイルがあったらサフィックスを変える
                suffix="_${i}"
            done
        else
            echo "rm: cannot remove '$item': No such file or directory" >&2
        fi
    done
}
alias rm=rm_wrap
alias rmv=/usr/bin/rm

# 他
alias vim="nvim"
alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='dif -h'
alias dot="cd ${HOME}/.dotfiles && nvim"
