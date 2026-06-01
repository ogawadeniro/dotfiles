# == シンボリックリンクを作成
# シンボリックリンク作成用ヘルパー
create_link() {
    target=$1
    link=$2
    # シンボリックリンクがない場合だけ作成する
    if [ ! -L "$link" ]; then
        echo "Create $target link to $link"
        ln -s "$target" "$link"
    fi
}

create_link "$HOME/.dotfiles/ghostty" "$HOME/.config/ghostty"
create_link "$HOME/.dotfiles/nvim" "$HOME/.config/nvim"
create_link "$HOME/.dotfiles/tmux" "$HOME/.config/tmux"
create_link "$HOME/.dotfiles/zsh" "$HOME/.config/zsh"
