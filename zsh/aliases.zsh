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
    local trash_dir="${HOME}/.local/share/Trash/files"
    if [ ! -e trash_dir ]; then
        mkdir -p ${trash_dir}
    fi
    mkdir -p "$trash_dir"
    for item in "$@"; do
        if [ -e "$item" ]; then
            # 捨て先に同名のファイルがなくなるまでサフィックスをインクリメントする。
            local suffix=""
            for i in $(seq 1 100); do
                # 捨てる先のパスに同じ名前のファイルがあるかどうか判定
                local dst="${trash_dir}/$(basename "$item")${suffix}"
                if [ ! -e "${dst}" ]; then
                    # 捨てる
                    mv "$item" "$dst"
                    if [ $? -eq 0 ]; then
                        echo "Moved to ${trash_dir}: ${item}"
                    else
                        echo "\e[31mFailed to trash: $item"
                    fi
                    break
                fi
                # 同名のファイルがあったらサフィックスをインクリメント
                suffix="_${i}"
            done
        else
            echo "\e[31mrm_wrap:\e[0m cannot remove '$item': No such file or directory" >&2
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
alias glog=git log --oneline --all --decorate -15 -p
