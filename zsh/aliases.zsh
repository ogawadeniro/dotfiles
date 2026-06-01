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

# 他
alias vim="nvim"
alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='dif -h'
